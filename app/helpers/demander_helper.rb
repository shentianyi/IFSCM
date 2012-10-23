#coding:utf-8
require 'csv'
require 'digest/md5'

module DemanderHelper
  # alias :PartNr  :
  def generate_by_csv(files,clientId)

    begin
      uuid=UUID.new
      upload_files_uuid=uuid.generate
      files_error_count=0
      batch_items_count=0
      upload_file_key_uuid=uuid.generate
      batch_items_key=uuid.generate
      $redis.hmset upload_files_uuid,'files:count',files.count,'files:key',upload_file_key_uuid,'batch:upload:items:key',batch_items_key
      files.each do |f|
        $redis.sadd upload_file_key_uuid,f[:uuidName]

        file_item_count=0
        file_item_error_count=0
        normal_items_key=uuid.generate
        error_items_key=uuid.generate
        $redis.hmset f[:uuidName],'oriName',f[:oriName],'uuidName',f[:uuidName],'normal:items:key',normal_items_key,'error:items:key',error_items_key
     
        # csv header
        CSV.foreach(File.join(f[:path],f[:pathName]),:headers=>true,:col_sep=>$CSVSP) do |row|
          file_item_count+=1
          demand= Demander.new :key=>Demander.gen_index,:cpartNr=>row[0],:clientId=>clientId,:supplierNr=>row[1],:filedate=>row[2],:type=>row[3],:amount=>row[4]
          # validate demand
          msg=demand_validate(demand,uuid.generate,uuid.generate,batch_items_key,file_item_count,f[:uuidName])
          file_item_error_count+= 1 if msg.result
          demand.vali=msg.result
         duuid=uuid.generate
          demand.save_temp_in_redis duuid,msg.countents
          if msg.result
            #cal rate and store in stored set
          else
            $redis.sadd error_items_key,duuid
          end
        end
      end
    rescue=>e
      puts e.to_s
    end
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
    end
    
    return msg
  end

  def cal_rate

  end
end

