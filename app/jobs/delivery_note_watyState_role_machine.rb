#encoding: utf-8
class DeliveryNoteWayStateRoleMachine
  @queue='delivery_client_queue'
  def self.perform id,action
    begin    
    puts "DeliveryNoteWayStateRoleMachine:#{id}--#{action}"
    dn=DeliveryNote.find(id)
    condi={}
    condi["delivery_notes.id"]=dn.id   
    condi["delivery_items.wayState"]=DeliveryObjWayState::Received       
    case action
      when DeliveryRoleMachineAction::DoSend
        dn.add_to_org_role dn.rece_org_id,OrgRoleType::DnReciver
      when DeliveryRoleMachineAction::DoReject
        dn.remove_from_org_role dn.rece_org_id,OrgRoleType::DnReciver
      when DeliveryRoleMachineAction::DoReceive
        condi["strategies.needCheck"]=[DeliveryObjInspect::SamInspect,DeliveryObjInspect::FullInspect]
        dn.remove_from_org_role dn.rece_org_id,OrgRoleType::DnReciver
        receive_total=dn.delivery_items.where(:wayState=>DeliveryObjWayState::Received).count        
        receive_needCheck=DeliveryItem.joins(:delivery_package=>{:part_rel=>:strategy}).joins(:delivery_package=>:delivery_note).count(:conditions=>condi)
        if receive_needCheck>0
           dn.add_to_org_role dn.rece_org_id,OrgRoleType::DnInspector
        end
        if receive_total>receive_needCheck
          dn.add_to_org_role dn.rece_org_id,OrgRoleType::DnInstorer
        end
      when DeliveryRoleMachineAction::DoReturn
        dn.remove_from_org_role dn.rece_org_id,OrgRoleType::DnInspector
        dn.remove_from_org_role dn.rece_org_id,OrgRoleType::DnInstorer
      when  DeliveryRoleMachineAction::DoInspect
        condi["delivery_items.checked"]=false        
        checked=DeliveryItem.joins(:delivery_package=>{:part_rel=>:strategy}).joins(:delivery_package=>:delivery_note).count(:conditions=>condi)
        if checked==0
          dn.remove_from_org_role dn.rece_org_id,OrgRoleType::DnInspector
          dn.add_to_org_role dn.rece_org_id,OrgRoleType::DnInstorer
        end
      when DeliveryRoleMachineAction::DoStore
        stored=dn.delivery_items.where(:wayState=>DeliveryObjWayState::Received,:stored=>false).count
        if stored==0
          dn.remove_from_org_role dn.rece_org_id,OrgRoleType::DnInstorer
        end
      end 
    rescue Exception=>e
     puts e.message
    end
  end
end