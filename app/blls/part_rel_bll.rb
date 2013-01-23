#coding:utf-8

module PartRelDll
  # ws redis search by conditions
  def  self.redis_search_by_conditions q,options=nil
    prms=[]
    result,total= Redis::Search.complete("PartRel",q,options)
    if result
      result.collect do |r|
        prms<<PartRel.new(r)
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
  # - int : psize, 可空
  # - int ： page, 可空
  # 返回值：
  # - PartRel : 对象数组
  # - int : total
  def self.get_part_rel_by_partnerNr orgId,partnerNr,orgOpeType,partNr=nil,psize=nil,page=nil
    t=OrganisationRelation.get_type_by_opetype(orgOpeType)
    if  partnerId=OrganisationRelation.get_partnerid(:oid=>orgId,:pt=>t,:pnr=>partnerNr)
      if  (partNr.nil? or partNr=="")
        return get_part_rel_by_partnerId orgId,partnerId,orgOpeType,psize,page
      elsif pid=Part.get_id(orgId,partNr)
        offset=startIndex
        count=startIndex.nil? ? nil:(endIndex-startIndex)
        return get_part_rel_metas_by_parterId_partId orgId,partnerId,orgOpeType,pid,offset,count
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
  # - int : psize, 可空
  # - int ： page, 可空
  # 返回值：
  # - PartRel : 对象数组
  # - int : total
  def self.get_part_rel_by_partnerId orgId,partnerId,orgOpeType,psize=nil,page=nil
    cid,sid=get_csId_by_orgOpeType(orgOpeType,orgId,partnerId)
    c={}
    c["organisation_relation.origin_client_id"]=cid
    c["organisation_relation.origin_supplier_id"]=sid
    count=PartRel.joins(:organisation_relation).find(:all,:conditions=>c).count   
    prs=PartRel.joins(:organisation_relation).limit(psize).offset(psize*page).find(:all,:conditions=>c) if count>0
    return prs,count
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
  # - PartRel : 对象数组
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
