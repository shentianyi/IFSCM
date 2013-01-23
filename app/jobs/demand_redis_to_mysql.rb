class DemandRedisToMysql
  include RedisFileHelper
  @queue='transform_queue'
  def self.perform batchId
    puts "do DemandUploadDataDiscarder:#{batchId}"
    RedisFileHelper::clean_batch_files_data batchId
  end
end