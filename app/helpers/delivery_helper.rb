#coding:utf-8

module DeliveryHelper
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
  
  def self.get_clientNr_by_orgId orgId,pid
    OrganisationRelation.get_parterNr(:oid=>orgId,:pt=>:c,:pid=>pid)
  end
      
  def self.get_supplierNr_by_orgId orgId,pid
    OrganisationRelation.get_parterNr(:oid=>orgId,:pt=>:s,:pid=>pid)
  end
  
end
