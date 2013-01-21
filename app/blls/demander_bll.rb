#coding:utf-8
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
      # batchFile.errorCount=0
      singleFileKeys=batchFile.get_normal_item_keys(0,-1)[0]
      items=[]
      singleFileKeys.each do |sfkey|
        sfile=RedisFile.find(sfkey)
        sfile.itemCount=sfile.errorCount=0
        CSV.foreach(File.join($DECSVP,sfile.uuidName),:headers=>true,:col_sep=>$CSVSP) do |row|
          if row["PartNr"] and row["Supplier"] and row["Date"] and row["Type"] and row["Amount"]
            sfile.itemCount+=1
            demand= DemanderTemp.new(:cpartNr=>row["PartNr"].strip,:clientId=>clientId,:supplierNr=>row["Supplier"].strip,
            :filedate=>row["Date"].strip,:type=>row["Type"].strip,:amount=>row["Amount"].strip,:lineNo=>sfile.itemCount,:source=>sfile.oriName,:oldamount=>0)
            demand.date=FormatHelper::demand_date_by_str_type(demand.filedate,demand.type)

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
    if !partId=Part.find_partKey_by_orgId_partNr(demand.clientId,demand.cpartNr)
      msg.result=false
      msg.content_key<<:pnrNotEx
    else
    demand.cpartId=partId
    end

    # vali supplier
    if client=Organisation.find_by_id(demand.clientId)
      if !supplierId=client.find_supplier_byNr(demand.supplierNr)
        msg.result=false
        msg.content_key<<:spNrNotEx
      else
      demand.supplierId=supplierId
      end
    end

    # vali part relation
    if partId and supplierId
      if !parts=PartRel.get_partRelMetas_by_partKey(demand.clientId,supplierId,partId,PartRelType::Client)
        msg.result=false
        msg.content_key<<:partNotFitOrgP
      else
        if parts.count>1
          msg.result=false
          msg.content_key<<:partMutiFitOrgP
        else
        demand.spartId=parts[0].spartId
        demand.relpartId=parts[0].key
        end
      end
    end

    # valid demand type
    if !DemandType.contains(demand.type)
      msg.result=false
      msg.content_key<<:fcTypeNotEx
    end

    # vali date
    if  FormatHelper::str_less_today(demand.filedate)
      msg.result=false
      msg.content_key<<:fcDateErr
    end

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


end
