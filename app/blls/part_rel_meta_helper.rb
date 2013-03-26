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
  # - string : partNr , 可空
  # - int : orgOpeType
  # - int : startIndex, 可空
  # - int ： endIndex, 可空
  # 返回值：
  # - PartRelMeat : 对象数组
  def self.get_part_rel_metas_by_parterNr orgId,partnerNr,orgOpeType,partNr=nil,startIndex=nil,endIndex=nil
    if org=Organisation.find_by_id(orgId)
      if  partnerId=org.get_parterId_by_parterNr(orgOpeType,partnerNr)
        if  (partNr.nil? or partNr=="")
          return get_part_rel_metas_by_parterId orgId,partnerId,orgOpeType,startIndex,endIndex
        elsif part=Part.find_by_partNr(orgId,partNr)
          offset=startIndex
          count=startIndex.nil? ? nil:(endIndex-startIndex)
          return get_part_rel_metas_by_parterId_partId orgId,partnerId,orgOpeType,part.id,offset,count
        end
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
    partRelType=get_partRelType_by_orgOpeType orgOpeType
    cId,sId=get_csId_by_orgOpeType orgOpeType,orgId,partnerId
    partRelMetas,total=PartRelMeta.get_by_orgId(cId,sId,partRelType,startIndex,endIndex)
    if startIndex
    return  partRelMetas,total
    end
    return partRelMetas
  end

  # ws
  # [功能：] 根据已建立关系的组织号、零件号 获得零件关系
  # 参数：
  # - int : orgId
  # - int : partnerId
  # - int : orgOpeType
  # - int : partId
  # - int : offset, 可空
  # - int ： count, 可空
  # 返回值：
  # - PartRelMeat : 对象数组
  def self.get_part_rel_metas_by_parterId_partId orgId,partnerId,orgOpeType,partId,offset=nil,count=nil
    partRelType=get_partRelType_by_orgOpeType orgOpeType
    cId,sId=get_csId_by_orgOpeType orgOpeType,orgId,partnerId
    partRelMetas,total=PartRelMeta.get_by_partId_orgId(cId,sId,partRelType,partId,offset,count)
    if offset
    return  partRelMetas,total
    end
    return partRelMetas
  end


  # ws
  # [功能：] 根据组织操作类型获取零件关系类型
  # 参数：
  # - int : orgOpeType
  # 返回值：
  # - PartRelType : 零件关系类型
  def self.get_partRelType_by_orgOpeType orgOpeType
    if orgOpeType==OrgOperateType::Client
      return  PartRelType::Client
    else
      return PartRelType::Supplier
    end
  end
  
    # ws
  # [功能：] 根据组织操作类型获取clientId,supplierId
  # 参数：
  # - int : orgOpeType
  # - int : orgId
  # - int : partnerId
  # 返回值：
  # - int : clientId
  # - int : supplierId
  def self.get_csId_by_orgOpeType orgOpeType,orgId,partnerId
    if orgOpeType==OrgOperateType::Client
      return  orgId,partnerId
    else
      return partnerId,orgId
    end
  end

end