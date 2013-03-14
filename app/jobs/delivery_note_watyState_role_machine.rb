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
      reciver=OrgRoleType::DnReciver
      inspector=OrgRoleType::DnInspector
      instorer=OrgRoleType::DnInstorer
      case action
      when DeliveryRoleMachineAction::DoSend
        dn.add_to_org_role dn.rece_org_id,reciver
      when DeliveryRoleMachineAction::DoReject
        dn.remove_from_org_role dn.rece_org_id,reciver
      when DeliveryRoleMachineAction::DoReceive
        condi["strategies.needCheck"]=[DeliveryObjInspect::SamInspect,DeliveryObjInspect::FullInspect]
        dn.remove_from_org_role dn.rece_org_id,reciver
        receive_total=dn.delivery_items.where(:wayState=>DeliveryObjWayState::Received).count
        receive_needCheck=DeliveryItem.joins(:delivery_package=>{:part_rel=>:strategy}).joins(:delivery_package=>:delivery_note).count(:conditions=>condi)
        if receive_needCheck>0
        dn.add_to_org_role dn.rece_org_id,inspector
        end
        if receive_total>receive_needCheck
        dn.add_to_org_role dn.rece_org_id,instorer
        end
      when DeliveryRoleMachineAction::DoReturn
        dn.remove_from_org_role dn.rece_org_id,inspector
        dn.remove_from_org_role dn.rece_org_id,instorer
      when  DeliveryRoleMachineAction::DoInspect
        condi["delivery_items.checked"]=false
        checked=DeliveryItem.joins(:delivery_package=>{:part_rel=>:strategy}).joins(:delivery_package=>:delivery_note).count(:conditions=>condi)
        if checked==0
          dn.remove_from_org_role dn.rece_org_id,inspector
          dn.add_to_org_role dn.rece_org_id,instorer if dn.wayState!=DeliveryObjWayState::Returned
          # part inspect strategy level
          c={}
          c["b.needCheck"]=[DeliveryObjInspect::SamInspect,DeliveryObjInspect::FullInspect]
          c["delivery_note_id"]=id
          select="sum(packAmount) as 'packAmount',b.part_rel_id"
          joins="join strategies as b on delivery_packages.part_rel_id=b.part_rel_id"
          packs=DeliveryPackage.group("b.part_rel_id").find(:all,:select=>select,:joins=>joins,:conditions=>c)
          c={}
          c["delivery_notes.id"]=id
          packs.each do |p|
            c["part_rels.id"]=p.part_rel_id
            c[:checked]=true
            c[:state]=DeliveryObjState::Normal
            count=DeliveryItem.joins(:delivery_package=>:delivery_note).joins(:delivery_package=>:part_rel).count(:conditions=>c)
            if count==p.packAmount
              if strategy=Strategy.find_by_part_rel_id(p.part_rel_id)
                if strategy.check_passed_times+1==strategy.demote_times
                  nextCheck=case strategy.needCheck
                  when DeliveryObjInspect::FullInspect
                    DeliveryObjInspect::SamInspect
                  when DeliveryObjInspect::SamInspect
                    DeliveryObjInspect::ExemInspect
                  else
                  DeliveryObjInspect::ExemInspect
                  end
                  strategy.update_attributes(:check_passed_times=>0,:needCheck=>nextCheck)
                else
                  strategy.update_attributes(:check_passed_times=>strategy.check_passed_times+1)
                end
              end
            else
              c[:state]=DeliveryObjState::Abnormal
              count=DeliveryItem.joins(:delivery_package=>:delivery_note).joins(:delivery_package=>:part_rel).count(:conditions=>c)
              if count>0
                if strategy=Strategy.find_by_part_rel_id(p.part_rel_id)
                 strategy.update_attributes(:check_passed_times=>0)
                end
              end
            end
          end
        #
        end
      when DeliveryRoleMachineAction::DoStore
        stored=dn.delivery_items.where(:wayState=>DeliveryObjWayState::Received,:stored=>false).count
        if stored==0
          dn.remove_from_org_role dn.rece_org_id,instorer
          DeliveryBll.clean_redis_dn dn.id
        end
      end
    rescue Exception=>e
      puts e.message
    end
  end
end