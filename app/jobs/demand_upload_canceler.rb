class DemandUploadCanceler
  include RedisFileHelper
  @queue='demand_queue'
  
  def self.perform batchId
    puts "do DemandUploadCanceler:#{batchId}"
    RedisFileHelper::delete_batch_files batchId
    RedisFileHelper::clean_batch_files_data batchId
  end

end