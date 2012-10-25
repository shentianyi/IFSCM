#coding:utf-8
require 'csv'
require 'digest/md5'

module DemanderHelper
  # ws: generate files demands from csvs
  def self.generate_by_csv(files,clientId)
    begin
      uuid=UUID.new
      # in batchFile normalKey=>file set, repeat Key=>repeat hash
      batchFile=RedisFile.new(:index=>uuid.generate,:itemCount=>0,:errorCount=>0,:normalItemKey=>uuid.generate,:repeatItemKey=>uuid.generate)
      files.each do |f|
        sfile=RedisFile.new(:index=>f[:uuidName],:oriName=>f[:oriName],:uuidName=>f[:uuidName],
        :itemCount=>0,:errorCount=>0,:normalItemKey=>uuid.generate,:errorItemKey=>uuid.generate)

        # csv header---
        CSV.foreach(File.join(f[:path],f[:pathName]),:headers=>true,:col_sep=>$CSVSP) do |row|

        sfile.itemCount+=1
          demand= Demander.new(:uuid=>uuid.generate,:cpartNr=>row[0],:clientId=>clientId,:supplierNr=>row[1],
          :filedate=>row[2],:type=>row[3],:amount=>row[4],:lineNo=>sfile.itemCount,:source=>f[:oriName])
          demand.date=FormatHelper::demand_date_by_str_type demand.filedate,demand.type

          # validate demand field
          msg=demand_field_validate(demand,batchFile)

          sfile.errorCount+= 1 if !msg.result
          demand.vali=msg.result
          demand.save_temp_in_redis msg.contents
          if msg.result
            sfile.add_normal_item demand.rate,demand.uuid
          else
            sfile.add_error_item demand.lineNo,demand.uuid
          end
        end
        # csv --end
        sfile.save_in_redis
        batchFile.add_normal_item sfile.errorCount,sfile.index # order the files by error items count
        batchFile.add_item sfile
        batchFile.errorCount+=1 if sfile.errorCount>0
        batchFile.itemCount+=1
      end
      batchFile.save_in_redis
      return batchFile
    rescue Exception=>e
      puts '-------------exception msg---------------------'
      puts e.message
      puts e.backtrace.inspect
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
    if !partId=Part.find_partId_by_orgId_partNr(demand.clientId,demand.cpartNr)
      msg.result=false
      msg.content_key<<:pnrNotEx
    else
    demand.cpartId=partId
    end

    # vali supplier
    if !supplierId=Organisation.search_supplier_byNr(demand.clientId,demand.supplierNr)
      msg.result=false
      msg.content_key<<:spNrNotEx
    else
    demand.supplierId=supplierId
    end

    # vali part relation
    if partId and supplierId
      if !parts=Part.get_supplier_parts(clientId,suplierId,partId)
        msg.result=false
        msg.content_key<<:partNotFitOrgP
      else
        if parts.count>1
          msg.result=false
          msg.content_key<<:partMutiFitOrgP
        else
        demand.spartId=parts
        end
      end
    end
    # valid demand type
    if !$redis.hget('demand:type',demand.type)
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
    if baseuuid=batchFile.get_repeat_item(repeat_key)
      baseDemand=Demander.find(baseuuid)
      msg.result=false
      msg.add_content("existsFile:#{baseDemand['source']},line#{baseDemand['lineNo']}")
    else
      batchFile.add_repeat_item(repeat_key,demand.uuid)
    end
    return msg
  end

  # ws: get file demands by type
  def self.get_file_demands fileId,startIndex,endIndex,type
    demands=RedisFile.new(:index=>fileId)
    itemKeys=demands.send "get_#{type}_item_keys".to_sym,startIndex,endIndex
    demands.itemCount=itemKeys.count
    if demands.itemCount>0
      demands.items=[]
      itemKeys.each do |k|
        h=Demander.find(k)
        if h.count>0
          demand=Demander.new(h)
        demands.items<<demand
        end
      end
    end
    return demands
  end

end
