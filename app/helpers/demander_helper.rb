#coding:utf-8
#encoding=utf-8
require 'csv'
require 'zip/zip'
require 'enum/part_rel_type'
require "iconv"

module DemanderHelper
  # ws : generate batch file index
  def self.generate_batchFile_index(files)
    batchFile=RedisFile.new(:key=>UUID.generate,:itemCount=>0,:errorCount=>0,:normalItemKey=>UUID.generate,:repeatItemKey=>UUID.generate,:finished=>false)
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
    returnMsg=ReturnMsg.new(:result=>false,:content=>'')
    batchFile=RedisFile.find(batchFileKey)
    batchFile.errorCount=0
    singleFileKeys=batchFile.get_normal_item_keys(0,-1)[0]
    items=[]
    singleFileKeys.each do |sfkey|
      sfile=RedisFile.find(sfkey)
      sfile.itemCount=sfile.errorCount=0

      CSV.foreach(File.join($DECSVP,sfile.uuidName),:headers=>true,:col_sep=>$CSVSP) do |row|
        if row.count>4
          sfile.itemCount+=1
          demand= DemanderTemp.new(:key=>UUID.generate,:cpartNr=>row[0],:clientId=>clientId,:supplierNr=>row[1],
          :filedate=>row[2],:type=>row[3],:amount=>row[4],:lineNo=>sfile.itemCount,:source=>sfile.oriName,:oldamount=>0)
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
          returnMsg.content="文件:#{sfile.oriName},行号:#{sfile.itemCount+1},少于5列,请重新修改上传！"
        return returnMsg
        end
      end
      # csv --end
      sfile.cover
      batchFile.remove_normal_item sfile.key
      batchFile.add_normal_item sfile.errorCount,sfile.key # order the files by error items count
      items<<sfile
      batchFile.errorCount+=1 if sfile.errorCount>0
    end
    batchFile.cover
    batchFile.items=items if items.count>0
    returnMsg.object=batchFile
    returnMsg.result=true
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
      if !supplierId=client.search_supplier_byNr(demand.supplierNr)
        msg.result=false
        msg.content_key<<:spNrNotEx
      else
      demand.supplierId=supplierId
      end
    end

    # vali part relation
    if partId and supplierId
      if !parts=PartRel.get_single_part_cs_parts(demand.clientId,supplierId,partId,PartRelType::Client)
        msg.result=false
        msg.content_key<<:partNotFitOrgP
      else
        if parts.count>1
          msg.result=false
          msg.content_key<<:partMutiFitOrgP
        else
          demand.spartId=parts[0].key
          demand.relpartId=PartRel.get_partRelMetaKey_by_partKey(demand.clientId,demand.supplierId,demand.cpartId,PartRelType::Client)
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
    if FormatHelper::str_is_notNum_less_zero(demand.amount false)
      msg.result=false
      msg.content_key<<:pAmountIsNotNumOrLessZero
    else
    demand.amount=demand.amount
    end

    #valid repeat
    repeat_key= demand.gen_md5_repeat_key
    if key=batchFile.get_repeat_item(repeat_key)
      puts 'repeat_key:'+repeat_key
      puts 'key:'+key
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
  def self.get_file_demands fileId,startIndex,endIndex,type
    demands=RedisFile.find(fileId)
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
    return demands,totalCount
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
    msg=ReturnMsg.new(:result=>false,:content=>'')
    path=nil
    if bf=RedisFile.find(batchId)
      # if bf.errorCount==0
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
                  nds,ncount=get_file_demands sf.key,0,-1,m
                  if ncount>0
                    nds.items.each do |nd|
                      f.puts [nd.cpartNr,nd.supplierNr,nd.filedate,nd.type,nd.amount].join($CSVSP)
                    end
                  end
                end
              end
            tmps<<spath
            #z.add(Iconv.iconv( 'GBK//IGNORE','utf-8//IGNORE',sf.oriName).to_s,spath)
            #   z.add(sf.oriName.decode('gbk'),spath)
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
    # else
    # msg.content='仍存在错误文件，请全部修改后再下载'
    # end
    else
      msg.content='上传文件被取消，无法下载'
    end
    return msg
  end
end
