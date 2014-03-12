#encoding: utf-8
module DemanderBll
  # ws : generate batch file index
  def self.generate_batchFile_index(files)
    batchFile=RedisFile.new(:itemCount=>0,:errorCount=>0,:normalItemKey=>UUID.generate,:repeatItemKey=>UUID.generate,:finished=>false)
    items=[]
    files.each do |f|
      sfile=RedisFile.new(:key=>f.uuidName,:oriName=>f.oriName,:uuidName=>f.pathName,
      :itemCount=>0,:errorCount=>0,:normalItemKey=>UUID.generate,:errorItemKey=>UUID.generate,:finished=>false)
      sfile.save
      items<<sfile
      batchFile.add_normal_item sfile.errorCount,sfile.key
      batchFile.itemCount+=1
    end
    batchFile.save
    batchFile.items=items
    return batchFile
  end

  # ws: handle batchFile from csv
  def self.handle_batchFile_from_csv(batchFileKey,clientId)
    begin
      returnMsg=ReturnMsg.new
      batchFile=RedisFile.find(batchFileKey)
      batchFile.errorCount=0
      singleFileKeys=batchFile.get_normal_item_keys(0,-1)[0]
      items=[]
      singleFileKeys.each do |sfkey|
        sfile=RedisFile.find(sfkey)
        sfile.itemCount=sfile.errorCount=0
        CSV.foreach(File.join($DECSVP,sfile.uuidName),:headers=>true,:col_sep=>$CSVSP) do |row|
          if row["PartNr"] and row["Supplier"] and row["Date"] and row["Type"] and row["Amount"]
            sfile.itemCount+=1
            if row["OrderNr"]
              demand= DemanderTemp.new(:cpartNr=>row["PartNr"].strip,:clientId=>clientId,:supplierNr=>row["Supplier"].strip,
              :filedate=>row["Date"].strip,:type=>row["Type"].strip,:amount=>row["Amount"].strip,:orderNr=>row["OrderNr"].strip,:lineNo=>sfile.itemCount,:source=>sfile.oriName,:oldamount=>0)
            else
              demand= DemanderTemp.new(:cpartNr=>row["PartNr"].strip,:clientId=>clientId,:supplierNr=>row["Supplier"].strip,
              :filedate=>row["Date"].strip,:type=>row["Type"].strip,:amount=>row["Amount"].strip,:orderNr=>"",:lineNo=>sfile.itemCount,:source=>sfile.oriName,:oldamount=>0)
            end
            # demand.date=FormatHelper::demand_date_by_str_type(demand.filedate,demand.type)
            demand.date=demand.filedate
            demand.inputed_at = row["InputDate"].nil? ? Time.now.to_i : Time.new(row["InputDate"].strip).to_i
            # validate demand field
            msg=demand_field_validate(demand,batchFile)
            demand.vali=msg.result
            if msg.result
              demand.rate,demand.oldamount=DemandHistory.compare_rate(demand)
            else
            demand.msg=msg.contents.to_json
            end
            demand.save

            if msg.result
            sfile.add_normal_item demand.rate.to_i.abs,demand.key
            else
            sfile.add_error_item demand.lineNo,demand.key
            sfile.errorCount+= 1
            end
          else
            returnMsg.content="文件:#{sfile.oriName},行号:#{sfile.itemCount+1},缺少列值或文件标题错误,请重新修改上传！"
          return returnMsg
          end
        end
        # csv --end
        if sfile.itemCount==0
          returnMsg.result=false
          returnMsg.content="文件:#{sfile.oriName},不存在预测"
        break
        end
        sfile.cover
        batchFile.remove_normal_item sfile.key
        batchFile.add_normal_item sfile.errorCount,sfile.key # order the files by error items count
        items<<sfile
        batchFile.errorCount+=1 if sfile.errorCount>0
        returnMsg.result=true
      end
      batchFile.cover
      batchFile.items=items if items.count>0
      returnMsg.object=batchFile
    rescue Exception=>e
      puts e.message
      puts e.backtrace
      returnMsg.content='文件格式错误,请重新上传'
    end
    return returnMsg
  end

  # ws: valid single demand
  def self.demand_field_validate demand,batchFile
    # valid msg
    msg=ValidMsg.new(:result=>true,:content_key=>Array.new)
    # vali partNr
    partId=supplierId=nil
    if partId=Part.get_id(demand.clientId,demand.cpartNr)
          demand.cpartId=partId
    else
      msg.result=false
      msg.content_key<<:pnrNotEx
    end

    # vali supplier
    if supplierId= OrganisationRelation.get_partnerid(:oid=>demand.clientId,:pt=>:s,:pnr=>demand.supplierNr)
      demand.supplierId=supplierId
    else   
     msg.result=false
      msg.content_key<<:spNrNotEx
    end

    # vali part relation
    if partId and supplierId
      if prId=PartRel.get_part_rel_id(:cid=>demand.clientId,:sid=>supplierId,:pid=>partId,:ot=>:c)
          demand.relpartId=prId
      else      
        msg.result=false
        msg.content_key<<:partNotFitOrgP
      end
    end

    # valid demand type
    if !DemandType.contains(demand.type)
      msg.result=false
      msg.content_key<<:fcTypeNotEx
    end

    # vali date
    # if FormatHelper::str_less_today(demand.filedate)
      # msg.result=false
      # msg.content_key<<:fcDateErr
    # end

    #if FormatHelper::demand_date_vali(demand.date,demand.type)
    #  msg.result=false
    #  msg.content_key<<:fcDateErr
    #end

    # vali amount
    if !FormatHelper::str_is_positive_float(demand.amount false)
      msg.result=false
      msg.content_key<<:amountIsNotPositiveFloat
    else
    demand.amount=demand.amount
    end

    #valid repeat
    repeat_key= demand.gen_md5_repeat_key
    if key=batchFile.get_repeat_item(repeat_key)
      baseDemand=DemanderTemp.find(key)
      if baseDemand and baseDemand.key!=demand.key
        msg.result=false
        msg.add_content("重复文件:#{baseDemand.source},行号:#{baseDemand.lineNo}")
      end
    else
    batchFile.add_repeat_item(repeat_key,demand.key)
    end
    return msg
  end

  # ws: get file demands by type
  def self.get_file_demands fileId,startIndex,endIndex,type=nil
    demands=RedisFile.find(fileId)
    type=demands.errorCount.to_i>0 ? 'error':'normal' if type.nil?
    itemKeys,totalCount=demands.send "get_#{type}_item_keys".to_sym,startIndex,endIndex
    demands.itemCount=itemKeys.count
    if demands.itemCount>0
      demands.items=[]
      itemKeys.each do |k|
        if d=DemanderTemp.find(k)
        demands.items<<d
        end
      end
    end
    return demands,type,totalCount
  end

  
  # ws : get batch file info
  def self.get_batch_file_info fileId,startIndex,endIndex
    bf=RedisFile.find(fileId)
    itemKeys,totalCount=bf.send "get_normal_item_keys".to_sym,startIndex,endIndex
    bf.itemCount,bf.errorCount,bf.created_at=bf.itemCount.to_i,bf.errorCount.to_i,bf.created_at.to_i
    if bf.itemCount>0
      bf.items=[]
      itemKeys.each do |k|
        if d=RedisFile.find(k)
        d.itemCount,d.errorCount=d.itemCount.to_i,d.errorCount.to_i
        bf.items<<d
        end
      end
    end
    return bf,totalCount
  end

  # ws : zip demand files
  def self.zip_demand_cvs batchId, user_agent
    msg=ReturnMsg.new
    path=nil
    if bf=RedisFile.find(batchId)
      sfKeys,scount=bf.get_normal_item_keys 0,-1
      if scount>0
        tmps=[]
        zfilename=File.join($DETMP, UUID.generate+'.zip')
        csv_encode=FormatHelper::csv_write_encode user_agent
        Zip::ZipFile.open(zfilename, Zip::ZipFile::CREATE) do |z|
          sfKeys.each do |sk|
            if sf=RedisFile.find(sk)
              spath=File.join($DETMP,sf.uuidName)
              File.open(spath,"wb:#{csv_encode}") do |f|
                f.puts $DECSVT.join($CSVSP)
                mt=['normal','error']
                mt.each do |m|
                  nds,type,ncount=get_file_demands sf.key,0,-1,m
                  puts "######{ncount}"
                  if ncount>0
                    nds.items.each do |nd|
                      f.puts [nd.cpartNr,nd.supplierNr,nd.filedate,nd.type,nd.amount,nd.orderNr].join($CSVSP)
                    end
                  end
                end
              end
            tmps<<spath
            z.add(sf.oriName,spath)
            end
          end
        end

        if tmps.count>0
          tmps.each do |t|
            File.delete(t)
          end
        end

      msg.result=true
      msg.content=zfilename
      else
        msg.content='批次上次中不存在任何文件'
      end
    else
      msg.content='上传文件被取消，无法下载'
    end
    return msg
  end

  # ws : download demands as csv
  def self.down_load_demand demands,opeType,user_agent
    msg=ReturnMsg.new
    csv_encode=FormatHelper::csv_write_encode user_agent
    path=File.join($DETMP,UUID.generate+'.csv')
    File.open(path,"wb:#{csv_encode}") do |f|
      if opeType==OrgOperateType::Client
        f.puts $DECSVTasC.join($CSVSP)
      elsif opeType==OrgOperateType::Supplier
        f.puts $DECSVTasS.join($CSVSP)
      end
      demands.each do |nd|
        if opeType==OrgOperateType::Client
          f.puts [nd.cpartNr,nd.spartNr,nd.supplierNr,nd.date,nd.type,nd.orderNr,nd.amount].join($CSVSP)
        elsif opeType==OrgOperateType::Supplier
          f.puts [nd.cpartNr,nd.spartNr,nd.clientNr,nd.date,nd.type,nd.orderNr,nd.amount].join($CSVSP)
        end
      end
    end
   msg.result=true
   msg.content=path
   return msg
  end
  
end
