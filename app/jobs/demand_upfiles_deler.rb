#encoding: utf-8
class DemandUpfilesDeler
  include RedisFileHelper
 
  @queue='demand_queue'
  def self.perform batchId
    puts "do DemandUpfilesDeler:#{batchId}"
    RedisFileHelper::delete_batch_files batchId  
  end
end