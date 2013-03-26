#encoding: utf-8
module PartBll
  def self.strategy_vali inspectType,warehouse_id,posiNr,demote,demote_times,least_amount
    msg=ValidMsg.new(:result=>true,:content_key=>Array.new)
    if !DeliveryObjInspect.get_desc_by_value inspectType
      msg.result=false
      msg.content_key<<:inpectTypeNotEx
    end

    if posiNr.length>0
      if posi=Position.where(:nr=>posiNr,:warehouse_id=>warehouse_id).first
      msg.object=posi.id
      else
        msg.result=false
        msg.content_key<<:posiNotEx
      end
    else
      msg.object=""
    end

    if least_amount.length>0
      if !FormatHelper.str_is_positive_float(least_amount) or !least_amount.to_f.between?(1,10000)
        msg.result=false
        msg.content_key<<:leastAmountIsNotPositiveFloat
      end
    end

    if demote
      if !FormatHelper.str_is_positive_integer(demote_times) or !demote_times.to_i.between?(1,10000)
        msg.result=false
        msg.content_key<<:demoteTimesNotIntBetween
      end
    end

    msg.content=msg.contents.join(',') if !msg.result
    return msg
  end

  def self.update_part_strategy ids,posi,inspect_type,demote,demote_times,least_amount
    Strategy.where(:part_rel_id=>ids).all.each do |strategy|
      data={}
      data[:leastAmount]=least_amount if least_amount.to_s.length>0
      data[:needCheck]=inspect_type
      data[:demote]=demote
      data[:demote_times]=demote_times
      data[:position_id]=posi if posi.to_s.length>0
      strategy.update_attributes(data)
    # strategy.update_attributes(:leastAmount=>least_amount, :needCheck=>inspect_type,:position_id=>posi)
    end
  end
end
