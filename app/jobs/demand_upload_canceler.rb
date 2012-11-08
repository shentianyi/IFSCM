class DemandUploadCanceler
  include RedisFileHelper
  @queue='demand_queue'
  
  def self.perform batchId
    puts "do DemandUploadCanceler:#{batchId}"
    RedisFileHelper::clean_batch_files_data batchId
    RedisFileHelper::delete_batch_files batchId
  end

end