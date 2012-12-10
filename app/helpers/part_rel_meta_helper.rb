#coding:utf-8

module PartRelMetaHelper
  # ws redis search by conditions
  def  self.redis_search_by_conditions q,options=nil
    prms=[]
    puts "q:#{q}"
    result,total= Redis::Search.complete("PartRelMeta",q,options)
    if result
      result.collect do |r|
        prms<<PartRelMeta.new(r)
      end
    end
    return prms,total if options[:startIndex]
    return prms
  end

  # ws
  # [功能：] 根据已建立关系的组织号获得零件关系
  # 参数：
  # - int : orgId
  # - string : partnerNr
  # - int : orgOpeType
  # - int : startIndex, 可空
  # - int ： endIndex, 可空
  # 返回值：
  # - PartRelMeat : 对象数组
  def self.get_part_rel_metas_by_parterNr orgId,partnerNr,orgOpeType,startIndex=nil,endIndex=nil
    if org=Organisation.find_by_id(orgId)
      if  partnerId=org.get_parterId_by_parterNr(orgOpeType,partnerNr)
        return get_part_rel_metas_by_parterId orgId,partnerId,orgOpeType,startIndex=nil,endIndex=nil
      end
    end
    return nil
  end

  # ws
  # [功能：] 根据已建立关系的组织号获得零件关系
  # 参数：
  # - int : orgId
  # - int : partnerId
  # - int : orgOpeType
  # - int : startIndex, 可空
  # - int ： endIndex, 可空
  # 返回值：
  # - PartRelMeat : 对象数组
  def self.get_part_rel_metas_by_parterId orgId,partnerId,orgOpeType,startIndex=nil,endIndex=nil
    partRelMetas=[]
    partRelType= if orgOpeType==OrgOperateType::Client
      PartRelType::Client
    else
      PartRelType::Supplier
    end
    
    return partRelMetas
 end
end