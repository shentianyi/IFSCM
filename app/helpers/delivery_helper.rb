#encoding: utf-8

module DeliveryHelper
  
    
  # ws
  # [功能：] 获得运单项状态
  # 参数：
  # - code : 状态码
  # 返回值：
  # - string : description
  def self.get_delivery_obj_state code
    DeliveryObjState.get_desc_by_value code
  end
  
  
  # ws
  # [功能：] 获得运单项状态 css class
  # 参数：
  # - code : 状态码
  # 返回值：
  # - string : css class
  def self.get_delivery_obj_state_css code
    cssClass=case code
    when DeliveryObjState::Normal
      'normal'
    when DeliveryObjState::Abnormal
      'abnorm'
    end
    return cssClass
  end
  
  def self.automake_di_temp staffId, d
      num = d.amount
      return false unless num.is_a?(Integer)
      if pr = PartRel.find_by_id(d.relpartId) and pinfo = pr.strategy
        least = pinfo.leastAmount
      else
        return false
      end
      pack = num/least
      dit=DeliveryItemTemp.new(:packAmount=>pack,:perPackAmount=>least,:part_rel_id=>d.relpartId,:spartNr=>PartRel.find(d.relpartId).supplier_part.partNr,
                                                            :total=>FormatHelper.string_multiply(least, pack))
      dit.save
      dit.add_to_staff_cache staffId
      if pack%least != 0
        dit=DeliveryItemTemp.new(:packAmount=>1,:perPackAmount=>least,:part_rel_id=>d.relpartId,:spartNr=>PartRel.find(d.relpartId).supplier_part.partNr,
                                                              :total=>FormatHelper.string_multiply(least, 1))
        dit.save
        dit.add_to_staff_cache staffId
      end
      return true
  end
                  
  # ws
  # [功能：] 获得运单运输状态
  # 参数：
  # - code : 状态码
  # 返回值：
  # - string : description
  def self.get_dn_wayState code
    DeliveryObjWayState.get_desc_by_value code
  end
  
   # ws
  # [功能：] 获得运单运输状态 css class
  # 参数：
  # - code : 状态码
  # 返回值：
  # - string : css class
  def self.get_dn_wayState_css code
    cssClass=case code
    when DeliveryObjWayState::Intransit
      'instransit'
    when DeliveryObjWayState::Received
      'received'
    when DeliveryObjWayState::Returned
      'returned'
    else
    'instransit'
    end
    return cssClass
  end

  
  def self.get_clientNr_by_orgId orgId,pid
    OrganisationRelation.get_parterNr(:oid=>orgId,:pt=>:c,:pid=>pid)
  end
      
  def self.get_supplierNr_by_orgId orgId,pid
    OrganisationRelation.get_parterNr(:oid=>orgId,:pt=>:s,:pid=>pid)
  end
  
  def self.get_dn_rece_address supplierId,clientId
    orl=OrganisationRelation.where(:origin_supplier_id=>supplierId,:origin_client_id=>clientId).first
    contact=DnContact.find_by_orid(orl.id)
    return contact.rece_address
  end
  
  # ws
  # [功能：] 获得包装箱检验策略名称
  # 参数：
  # - code : 状态码
  # 返回值：
  # - string : description
  def self.get_pack_check_inspect code
    DeliveryObjInspect.get_desc_by_value code
  end
  
  # ws
  # [功能：] 获得运单可以质检状态
  # 参数：
  # - 无
  # 返回值：
  # - string : description
  def self.get_can_inspect_states
    descs=[]
    DeliveryNote.get_can_inspect_codes.each do |code|
     descs<<get_dn_wayState(code)
    end
    descs
  end
  
end
