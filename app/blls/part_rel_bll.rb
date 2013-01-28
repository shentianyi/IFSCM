#encoding: utf-8
module PartRelBll
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
        return get_part_rels_by_partnerId_partId orgId,partnerId,orgOpeType,pid
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
    cid,sid,part=get_csId_by_orgOpeType(orgOpeType,orgId,partnerId)
    c={}
    c["organisation_relations.origin_client_id"]=cid
    c["organisation_relations.origin_supplier_id"]=sid
    select="part_rels.*,parts.partNr"
    count=PartRel.joins(:organisation_relation).count(:conditions=>c)
    prs=PartRel.joins(:organisation_relation).joins(part).limit(psize).offset(psize*page).find(:all,:select=>select,:conditions=>c) if count>0
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
  def self.get_part_rels_by_partnerId_partId orgId,partnerId,orgOpeType,partId
    cid,sid,part,ot=get_csId_by_orgOpeType(orgOpeType,orgId,partnerId)
      prid=PartRel.get_part_rel_id(:cid=>cid,:sid=>sid,:pid=>partId,:ot=>ot)
      c={}
      c["parts.id"]=partId
      select="part_rels.*,parts.partNr"
      prs=PartRel.joins(part).find(:all,:select=>select,:conditions=>c)
     return prs,1
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
    return  orgId,partnerId,:client_part,:c
    else
    return partnerId,orgId,:supplier_part,:s
    end
  end

end
