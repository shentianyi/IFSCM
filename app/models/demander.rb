#encoding: utf-8
require "base_class"
class Demander < ActiveRecord::Base
  self.inheritance_column = "not_used_type"
  attr_accessible :id, :created_at, :updated_at
  attr_accessible :key, :clientId,:relpartId,:supplierId, :type,:amount,:oldamount,:date,:rate, :accepted
  attr_accessible :orderNr, :order_item_id
  NumPer=$DEPSIZE
  
  include CZ::BaseModule
  include DemanderRedisIndex
  extend  DemanderNewbie
  # ws : add demand history
  def add_to_history history_key
    zset_key=DemandHistory.generate_zset_key self.clientId,self.supplierId,self.relpartId,self.type,self.date
    $redis.zadd(zset_key,Time.now.to_i,history_key)
  end

  def clientNr
    OrganisationRelation.get_partnerNr(:oid=>supplierId,:pt=>:c,:pid=>clientId)
  end

  def supplierNr
    OrganisationRelation.get_partnerNr(:oid=>clientId,:pt=>:s,:pid=>supplierId)
  end

  def cpartNr
    PartRel.find(relpartId).client_part.partNr
    # Part.get_partNr clientId,partId
  end

  def spartNr
    PartRel.find(relpartId).supplier_part.partNr
  end

  # ws
  # [功能：] 添加零件CF记录
  # 参数：
  # - Demander : demand
  # 返回值：
  # - 无
  def update_cf_record
    zsetKey=Demander.generate_partrel_cf_zset_key(self.relpartId, self.type)
    if !$redis.zscore zsetKey,self.key
      $redis.zadd zsetKey,self.date.to_i,self.key
    end
  end
  
  def amount t=nil
    return FormatHelper::get_number @attributes["amount"],t
  end

  def oldamount t=nil
    return FormatHelper::get_number @attributes["oldamount"],t
  end
  
  def self.find_by_key( k )
    if d = Demander.rfind( k )
      return d
    elsif d = Demander.where( :key=>k ).first
      return d
    else
      return nil
    end
  end
  
  def self.get_cf_by_range( iRelpartId, tStart, tEnd, type )
    zsetKey=Demander.generate_partrel_cf_zset_key( iRelpartId, type)
    arr = $redis.zrangebyscore( zsetKey, tStart, tEnd )
    return nil  if arr.size==0
    first = arr.first
    last = arr.last
    return nil  unless deLast = Demander.find_by_key( last )
    index = $redis.zrank( zsetKey, first )
    if index>0
      index -= 1
      first = $redis.zrange( zsetKey, index, index ).first
    else
      return deLast.amount
    end
    return nil  unless deFirst = Demander.find_by_key( first )
    cf = deLast.amount - deFirst.amount
    if cf >= 0
      return cf
    else
      return nil
    end
  end

  private

  def self.gen_kestrel( sId )
    "#{sId}:#{Rns::De}:#{Rns::Kes}"
  end

  def self.generate_partrel_cf_zset_key iPartrelId,type
    # "cId:#{orgId}:partrelId:#{partrelId}:spId:#{supplierId}:type:#{type}:cf:zset"
    "cf:zset:partrelId:#{iPartrelId}:type:#{type}"
  end
  
end