#encoding: utf-8
class PartStrategyUpdater

  @queue='part_client_queue'
  def self.perform ids,posi,inspect_type,demote,demote_times,least_amount
    begin
      puts "PartStrategyUpdater:#{ids}--#{inspect_type}"
      PartBll.update_part_strategy ids,posi,inspect_type,demote,demote_times,least_amount
    rescue Exception=>e
      puts e.message
    end
  end
end