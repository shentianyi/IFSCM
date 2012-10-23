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
        upload_file_key_uuid=uuid.generate
        batch_upload_items_key=uuid.generate
      #  $redis.hset upload_files_uuid,'files_count',files.count,'files_key',upload_file_key_uuid,'batch_upload_items_key',batch_upload_items_key
          files.each do |f|
          #  $redis.sadd upload_file_key_uuid,f[:uuidName]
            
            file_valid=true
            file_item_count=0
            file_item_error_count=0
            file_items_key=uuid.generate
           # $redis.hset f[:uuidName],'file_items_key',file_items_key
            # csv header
            CSV.foreach(File.join(f[:path],f[:pathName]),:headers=>true,:col_sep=>$CSVSP) do |row|
             file_item_count+=1
            # demand= Demander.new :cpartNr=>row[0],:clientId=>clientId,:supplierNr=>row[1],:filedate=>row[2],:type=>row[3],:amount=>row[4]
              # validate demand
               
              #-------------
            end
          end
      rescue=>e
        puts e.to_s
      end
    end
    
    def demand_validate demand,file_items_key,batch_key
             # gen md5 key
             demand.gen_md5_key
             demand.gen_md5_repeat_key
             
             # check repeat in batch
             if $redis.sismember batch_key,demand.md5repeatKey
             # check redis
             if demand.redis_validated # demand has ben checked              
              $redis.sadd file_items_key,demand.md5key
              if $redis.hget(demand.md5key,'valid')=='false'
                file_valid=false
              end
             else
               # valid msg
               msg=ValidMsg.new
               # vali partNr
               partId=supplierId=nil
               if !partId=Part.find_partId_by_orgId_partNr(clientId,demand.cpartNr)
                 msg.result=false
                 msg.content_key<<:pnrNotEx
               else
                 demand.cpartId=partId
               end
               # vali supplier
               if !supplierId=Organisation.search_supplier_byNr(clientId,demand.supplierNr)
                 msg.result=false
                 msg.content_key<<:spNrNotEx
               else
                 demand.supplierId=supplierId
               end
               
               # vali part relation
               if partId and supplierId
                 if !parts=Part.get_supplier_parts(clientId,suplierId,partId)
                   msg.result=false
                   msg.content_key<<:partNotFitSp
                 else
                   if parts.count>1
                     msg.result=false
                     msg.content_key<<:partNotFitSp
                   else
                     demand.spartId=parts[0][:partId]
                     demand.spartNr=parts[0][:partNr]
                   end
                 end
               end
               
               # vali date
               if  DateHelper::str_less_today(demand.filedate)
                 msg.result=false
                 msg.content_key<<:fcDateErr
               end
               
               end
          end
    end
end
