#coding:utf-8
require "base_class"
class Demander < ActiveRecord::Base
  attr_accessible :id, :created_at, :updated_at
  attr_accessible :key, :clientId,:relpartId,:supplierId, :type,:amount,:oldamount,:date,:rate
  NumPer=$DEPSIZE
  
  include CZ::BaseModule
  include DemanderRedisIndex
  extend  DemanderNewbie
  # ws : add demand history
  def add_to_history history_key
    zset_key=DemandHistory.generate_zset_key @clientId,@supplierId,@relpartId,@type,@date
    $redis.zadd(zset_key,Time.now.to_i,history_key)
  end

  def clientNr
    Organisation.find_by_id(supplierId).search_client_byId( clientId )
  end

  def supplierNr
    Organisation.find_by_id(clientId).search_supplier_byId( supplierId )
  end

  def cpartNr
    Part.find(PartRelMeta.find(relpartId).cpartId).partNr
  end

  def spartNr
    Part.find(PartRelMeta.find(relpartId).spartId).partNr
  end

  # ws
  # [功能：] 添加零件CF记录
  # 参数：
  # - Demander : demand
  # 返回值：
  # - 无
  def update_cf_record
    zsetKey=Demander.generate_org_part_cf_zset_key(self.clientId,self.relpartId,self.supplierId,self.type)
    if !$redis.zscore zsetKey,self.key
      $redis.zadd zsetKey,Time.parse(self.date).strftime('%Y%m%d').to_i,self.key
    end
  end

  def amount t=nil
    return FormatHelper::get_number @attributes["amount"],t
  end

  def oldamount t=nil
    return FormatHelper::get_number @oldamount,t
  end

  private

  def self.gen_kestrel( sId )
    "#{sId}:#{Rns::De}:#{Rns::Kes}"
  end

  def self.generate_org_part_cf_zset_key orgId,partrelId,supplierId,type
    "cId:#{orgId}:partrelId:#{partrelId}:spId:#{supplierId}:type:#{type}:cf:zset"
  end

end