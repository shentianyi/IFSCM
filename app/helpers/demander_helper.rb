#coding:utf-8
#encoding=UTF-8
require 'csv'
require 'zip/zip'
require 'enum/part_rel_type'
require "iconv"  

module DemanderHelper
  # ws: generate files demands from csvs
  def self.generate_by_csv(files,clientId)
    begin
      uuid=UUID.new
      # in batchFile normalKey=>file set, repeat Key=>repeat hash
      batchFile=RedisFile.new(:key=>uuid.generate,:itemCount=>0,:errorCount=>0,:normalItemKey=>uuid.generate,:repeatItemKey=>uuid.generate,:finished=>false)
      items=[]
      files.each do |f|
        sfile=RedisFile.new(:key=>f[:uuidName],:oriName=>f[:oriName],:uuidName=>f[:pathName],
        :itemCount=>0,:errorCount=>0,:normalItemKey=>uuid.generate,:errorItemKey=>uuid.generate,:finished=>false)
        # csv header---
        CSV.foreach(File.join(f[:path],f[:pathName]),:headers=>true,:col_sep=>$CSVSP) do |row|
        sfile.itemCount+=1
          demand= DemanderTemp.new(:key=>uuid.generate,:cpartNr=>row[0],:clientId=>clientId,:supplierNr=>row[1],
          :filedate=>row[2],:type=>row[3],:amount=>row[4],:lineNo=>sfile.itemCount,:source=>f[:oriName],:oldamount=>0)
          demand.date=FormatHelper::demand_date_by_str_type demand.filedate,demand.type

          # validate demand field
          msg=demand_field_validate(demand,batchFile)

          demand.vali=msg.result
          if msg.result
            demand.rate,demand.oldamount=DemandHistory.compare_rate(
          demand.clientId,demand.supplierId,
          demand.relpartId,demand.type,demand.date,demand.amount)
          else
          demand.msg=msg.contents.to_json
          end
          demand.save

          sfile.errorCount+= 1 if !msg.result
          if msg.result
          sfile.add_normal_item demand.rate.to_i.abs,demand.key
          else
          sfile.add_error_item demand.lineNo,demand.key
          end
        end
        # csv --end
        sfile.save
        batchFile.add_normal_item sfile.errorCount,sfile.key # order the files by error items count
        items<<sfile
        batchFile.errorCount+=1 if sfile.errorCount>0
        batchFile.itemCount+=1
      end
      batchFile.save
      batchFile.items=items if items.count>0
      return batchFile
    rescue Exception=>e
      puts '-------------exception msg---------------------'
      puts e.message
      puts e.backtrace.inspect.split(',')
    # should move all file infos from redis
    end
    return nil
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
        puts 'supplierId:'+supplierId
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
          demand.relpartId=PartRel.get_partrelId_by_partKey(demand.clientId,demand.supplierId,demand.cpartId,PartRelType::Client)
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
    if FormatHelper::str_is_notint_less_zero(demand.amount)
      puts 'amount:'+demand.amount
      msg.result=false
      msg.content_key<<:pAmountIsIntOrLessZero
    else
    demand.amount=demand.amount.to_i
    end

    #valid repeat
    repeat_key= demand.gen_md5_repeat_key
    if key=batchFile.get_repeat_item(repeat_key)
      puts 'repeat_key:'+repeat_key
      puts 'key:'+key
      baseDemand=DemanderTemp.find(key)
      if baseDemand and baseDemand.key!=demand.key
        msg.result=false
        msg.add_content("existsFile:#{baseDemand.source},line#{baseDemand.lineNo}")
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

  # ws : zip demand files
  def self.zip_demand_cvs batchId
    msg=ReturnMsg.new(:result=>false,:content=>'')
    path=nil
    if bf=RedisFile.find(batchId)
      # if bf.errorCount==0
        sfKeys,scount=bf.get_normal_item_keys 0,-1
        if scount>0
          tmps=[]
          zfilename=File.join($DETMP, UUID.generate+'.zip')
          Zip::ZipFile.open(zfilename, Zip::ZipFile::CREATE) do |z|
            sfKeys.each do |sk|
              puts 'sk'
               puts sk
               puts 'sk--'
              if sf=RedisFile.find(sk)
                spath=File.join($DETMP,sf.uuidName)
                File.open(spath,'w+') do |f|
                  f.puts $DECSVT.join($CSVSP)
                  
                  nds,ncount=get_file_demands sf.key,0,-1,'normal'
                  if ncount>0
                    nds.items.each do |nd|
                      f.puts [nd.cpartNr,nd.supplierNr,nd.filedate,nd.type,nd.amount].join($CSVSP)
                    end
                  end
                   eds,ecount=get_file_demands sf.key,0,-1,'error'
                  if ecount>0
                    eds.items.each do |ed|
                      f.puts [ed.cpartNr,ed.supplierNr,ed.filedate,ed.type,ed.amount].join($CSVSP)
                    end
                  end
                  
                end
                tmps<<spath
                  # z.add(Iconv.iconv("GBK//IGNORE", "UTF-8//IGNORE",sf.oriName),spath)
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
