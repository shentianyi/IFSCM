#coding:utf-8
require 'csv'
require 'digest/md5'

module DemanderHelper
  # ws: generate files demands from csvs
  def self.generate_by_csv(files,clientId)
    begin
      uuid=UUID.new
      # in batch_file normalKey=>file set, repeat Key=>repeat hash
      batch_file=RedisCsvFile.new(:index=>uuid.generate,:itemCount=>0,:errorCount=>0,:normalItemKey=>uuid.generate,:repeatItemKey=>uuid.generate)
      files.each do |f|
        sfile=RedisCsvFile.new(:index=>f[:uuidName],:oriName=>f[:oriName],:uuidName=>f[:uuidName],
        :itemCount=>0,:errorCount=>0,:normalItemKey=>uuid.generate,:errorItemKey=>uuid.generate)
        puts sfile
        # csv header---
        CSV.foreach(File.join(f[:path],f[:pathName]),:headers=>true,:col_sep=>$CSVSP) do |row|
        
          sfile.itemCount+=1
          demand= Demander.new(:cpartNr=>row[0],:clientId=>clientId,:supplierNr=>row[1],
                  :filedate=>row[2],:type=>row[3],:amount=>row[4],:lineNo=>sfile.itemCount)
          demand.date=FormatHelper::demand_date_by_str_type demand.filedate,demand.type
          # validate demand
          msg=demand_validate(demand)

          #valid repeat
          repeat_key= demand.gen_md5_repeat_key
          if repeatItem=batch_file.get_repeat_item(repeat_key)
            msg.result=false
            repeatItem=JSON.parse(repeatItem)
            puts repeatItem
            puts repeatItem.class 
            msg.add_content("existsFile:#{repeatItem['oriName']},line#{repeatItem['line']}")
          else
            batch_file.set_repeat_item(repeat_key,{:oriName=>f[:oriName],:line=>demand.lineNo}.to_json)
          end

          sfile.errorCount+= 1 if !msg.result
          demand.vali=msg.result
          duuid=uuid.generate
          demand.uuid=duuid
          demand.save_temp_in_redis duuid,msg.countents
          if msg.result
            sfile.add_normal_item demand.rate,duuid
          else
            sfile.add_error_item sfile.itemCount,duuid
          end
        end
        # csv --end
        sfile.save_in_redis
        batch_file.add_normal_item sfile.errorCount,sfile.index # order the files by error items count  
        batch_file.add_item sfile     
        batch_file.errorCount+=1 if sfile.errorCount>0
        batch_file.itemCount+=1
      end
      batch_file.save_in_redis
      return batch_file
    rescue Exception=>e
      puts '-------------exception msg---------------------'
      puts e.message
      puts e.backtrace.inspect
      # should move all file infos from redis
    end
    return nil
  end
  
  # ws: valid single demand
  def self.demand_validate demand
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
    if FormatHelper::str_is_int_less_zero(demand.amount)
      puts 'amount:'+demand.amount
      msg.result=false
      msg.content_key<<:pAmountIsIntOrLessZero
    else
    demand.amount=demand.amount.to_i
    end

    return msg
  end
  
  # ws: get file demands by type
  def self.get_file_demands fileId,startIndex,endIndex,type
    demands=RedisCsvFile.new(:index=>fileId)
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

