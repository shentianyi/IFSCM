#coding:utf-8
require 'csv'
require 'digest/md5'

module DemanderHelper
  # alias :PartNr  :
  def generate_by_csv(files,clientId)
    begin
      uuid=UUID.new
      # in batch_file normalKey=>file set, repeat Key=>repeat hash
      batch_file=RedisCsvFile.new(:index=>uuid.generate,:itemCount=>0,:errorCount=>0,:normalItemKey=>uuid.generate,:repeatItemKey=>uuid.generate)
      files.each do |f|
        sfile=RedisCsvFile.new(:index=>f[:uuidName],:oriName=>f[:oriName],:uuidName=>f[:uuidName],
        :itemCount=>0,:errorCount=>0,:normalItemKey=>uuid.generate,:errorItemKey=>uuid.generate)
        # csv header---
        CSV.foreach(File.join(f[:path],f[:pathName]),:headers=>true,:col_sep=>$CSVSP) do |row|
          file_item_count+=1
          demand= Demander.new :key=>Demander.gen_index,:cpartNr=>row[0],:clientId=>clientId,:supplierNr=>row[1],:filedate=>row[2],:type=>row[3],:amount=>row[4]
          demand.date=FormatHelper::demand_date_by_str_type demand.filedate,demand.type
          # validate demand
          msg=demand_validate(demand)

          #valid repeat
          repeat_key= demand.gen_md5_repeat_key
          if repeatItem=batch_file.get_repeat_item(repeat_key)
            msg.result=false
            repeat_item=JSON.parse(repeatItem)
            msg.add_content("existsFile:#{repeat_item[:oriName]},line#{repeat_item[:line]}")
          else
            batch_file.set_repeat_item(repeat_key,{:oriName=>f[:oriName],:line=>file_item_count}.to_json)
          end

          sfile.errorCount+= 1 if msg.result
          demand.vali=msg.result
          duuid=uuid.generate
          demand.save_temp_in_redis duuid,msg.countents
          if msg.result
            sfile.add_normal_item demand.rate,duuid
          else
            sfile.add_error_item duuid
          end
        end
        # csv --end
        batch_file.add_normal_item sfile.errorCount,sfile.index # order the files by error items count       
        batch_file.errorCount+=1 if sfile.errorCount>0
        batch_file.itemCount+=sfile.itemCount
        sfile.save_in_redis
      end
      batch_file.save_in_redis
      return batch_file.index,batch_file.errorCount>0
    rescue=>e
      puts e.to_s
    end
    return nil
  end

  def demand_validate demand
    # valid msg
    msg=ValidMsg.new
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
    if FormatHelper::str_is_int_less_zero(demand.amount)
      msg.result=false
      msg.content_key<<:pAmountIsIntOrLessZero
    else
    demand.amount=demand.amount.to_i
    end

    return msg
  end
end

