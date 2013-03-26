#encoding: utf-8

module PartHelper
  def self.get_inpect_type_image code,nw=nil
    img=case code
    when DeliveryObjInspect::ExemInspect
      'iconnocheck.png'
    when  DeliveryObjInspect::SamInspect
      'iconpickcheck.png'
    when  DeliveryObjInspect::FullInspect
      'iconcheck.png'
    end
    img='nw-'+img if nw
    return img
  end
end