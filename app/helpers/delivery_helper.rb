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
  
  def self.automake_di_temp staffId, demand
      num = demand.amount
      return false unless num.is_a?(Integer)
      pack = num/10
      dit=DeliveryItemTemp.new(:packAmount=>pack,:perPackAmount=>10,:partRelId=>demand.relpartId,
                                                            :total=>FormatHelper.string_multiply(10, pack))
      dit.save
      dit.add_to_staff_cache staffId
      if pack%10 != 0
        dit=DeliveryItemTemp.new(:packAmount=>1,:perPackAmount=>10,:partRelId=>demand.relpartId,
                                                              :total=>FormatHelper.string_multiply(10, 1))
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
    DeliveryNoteWayState.get_desc_by_value code
  end
  
   # ws
  # [功能：] 获得运单运输状态 css class
  # 参数：
  # - code : 状态码
  # 返回值：
  # - string : css class
  def self.get_dn_wayState_css code
    cssClass=case code
    when DeliveryNoteWayState::Intransit
      'instransit'
    when DeliveryNoteWayState::Received
      'received'
    when DeliveryNoteWayState::Returned
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
  
end
