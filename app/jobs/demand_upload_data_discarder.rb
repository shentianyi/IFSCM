#encoding: utf-8
class DemandUploadDataDiscarder
  include RedisFileHelper
  @queue='demand_queue'
  def self.perform batchId
    puts "do DemandUploadDataDiscarder:#{batchId}"
    RedisFileHelper::clean_batch_files_data batchId
  end
end