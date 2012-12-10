#coding:utf-8

module PartRelHelper
  # ws
  # [功能：] 建立客户-供应商零件关系
  # 参数：
  # - hash : args=>{cpart,spart,saleNo,purchaseNo}
  # 返回值：
  # - bool : success
  def self.generate_cs_part_relation args={}
    success=false
  #begin
    args[:partRelType]=PartRelType::Client
      gen_cs_part_relation args
      args[:partRelType]=PartRelType::Supplier
      gen_cs_part_relation args
    # rescue Exception=>e
      # puts e
    # end
    return false
  end

  private

  # ws
  # [功能：] 建立零件关系
  # 参数：
  # - hash : args=>{cpart,spart,saleNo,purchaseNo,:partRelType}
  # 返回值：
  # - 无
  def self.gen_cs_part_relation args={}
    cpart=args[:cpart]
    spart=args[:spart]
    if args[:partRelType]==PartRelType::Client
      partA=args[:cpart]
      partB=args[:spart]
    else
      partB=args[:cpart]
      partA=args[:spart]
    end
    # check partA has been build relation
    if partRel=PartRel.get_cs_partRel(cpart.orgId,spart.orgId,partA.key,args[:partRelType])
      puts "--------------#{partA.key} has been build part rel-----------"
      metas=PartRel.get_partRelMetas_by_partKey( cpart.orgId,spart.orgId,partA.key,args[:partRelType])
      meta_arr= get_part_metas(metas,args[:partRelType])
      if !meta_arr.include?(partB.key)
        puts "---------------------#{partA.key} has not build rel with #{partB.key}-----------------------"
        gen_partRelMeta_relation(cpart,spart,partA,partB,args[:saleNo],args[:purchaseNo],args[:partRelType])
      end
    else 
      puts "--------------#{partA.key} has not been build part rel-----------"
      gen_partRelMeta_relation(cpart,spart,partA,partB,args[:saleNo],args[:purchaseNo],args[:partRelType])
      partMetaSetKey=PartRelMeta.generate_cs_partRel_meta_set_key cpart.orgId,spart.orgId,partA.key
      partRel=PartRel.new(:key=>UUID.generate,:cId=>cpart.orgId,:sId=>spart.orgId,:type=>args[:partRelType],:partMetaSetKey=>partMetaSetKey)
      partRel.save
      partRel.add_to_org_part_zset partA.orgId,partA.key,args[:partRelType]
      partRel.add_to_org_cs_part_hash partA.key,args[:partRelType]
    end
  end


def self.get_part_metas metas,type
  if type==PartRelType::Client
    return   metas.collect{|m| m.spartId}
  else
    return  metas.collect{|m| m.cpartId}
  end
end

def self.gen_partRelMeta_relation  cpart,spart,partA,partB,saleNo,purchaseNo,partRelType
  puts "------------#{partA.key} & #{partB.key} has no rel, build it--------------------"
  partRelMeta=PartRelMeta.new(:key=>PartRelMeta.gen_key,:cpartId=>cpart.key,:spartId=>spart.key,:saleNo=>saleNo,:purchaseNo=>purchaseNo)
  partRelMeta.save
  partRelMeta.add_to_org_relmeta_zset partA.orgId,partB.orgId.to_i,partA.id,partRelType
  partRelMeta.add_to_org_part_relmeta_set cpart.orgId,spart.orgId,partA.key
  return partRelMeta
end
end