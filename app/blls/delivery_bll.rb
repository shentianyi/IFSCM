#encoding: utf-8
module DeliveryBll
  # ws
  # [功能：] 验证包装箱数和单位数量是否合法
  # 参数：
  # - string : metaKey
  # - string : packAmount
  # - string : perPackAmount
  # - string :staffId
  # 返回值：
  # - ValidMsg : 验证消息
  def self.vali_di_temp metaKey,packAmount,perPackAmount,staffId
    msg=ValidMsg.new(:result=>true,:content_key=>Array.new)
    # vali partRelMetaKey
    if !pr=PartRel.find(metaKey)
      msg.result=false
      msg.content_key<<:partRelMetaNotEx
    else
      if dit=DeliveryItemTemp.single_or_default(staffId)
        if pr.organisation_relation_id!=PartRel.find(dit.part_rel_id).organisation_relation_id
          msg.result=false
          msg.content_key<<:notSameClient
        end
      end
    end
    # vali packAmount
    if !FormatHelper::str_is_positive_integer packAmount
      msg.result=false
      msg.content_key<<:packAmountIsNotInt
    end
    # vali perPackAmount
    if !FormatHelper::str_is_positive_float perPackAmount
      msg.result=false
      msg.content_key<<:perPackAmountIsNotFloat
    end

    msg.content=msg.contents.join(',') if !msg.result
    return msg
  end

  def self.vali_current_di_temp staffId, orgRelIds
    temps=DeliveryItemTemp.get_staff_cache(staffId).first ||[]
    ids = temps.collect {|t| PartRel.find_by_id(t.part_rel_id.to_i).organisation_relation_id}
    len = (ids+orgRelIds).uniq.size
    return true  if len==1
    return false
  end

  # ws
  # [功能：] 生成运单
  # 参数：
  # - int : staffId
  # - int : orgId
  # - string : desiOrgNr
  # 返回值：
  # - ReturnMsg : JSON
  def self.build_delivery_note staffId,orgId,desiOrgNr,cusDnnr
    msg=ReturnMsg.new
    if desiOrgId=OrganisationRelation.get_partnerid(:oid=>orgId,:pt=>:c,:pnr=>desiOrgNr)
      #get di temps
      if temps=DeliveryItemTemp.get_staff_cache(staffId)[0]
        #new delivery note
        dstate=DeliveryObjState::Normal
        dnKey=ClassKeyHelper::gen_key("DeliveryNote")
        cusDnnr = cusDnnr.blank? ? dnKey : cusDnnr
        dn=DeliveryNote.new(:key=>dnKey,
        :state=>dstate,:staff_id=>staffId,:organisation_id=>orgId,:rece_org_id=>desiOrgId,:cusDnnr=>cusDnnr)
        temps.each do |t|
          packcount=t.packAmount
          pl=PartRelInfo.find(t.part_rel_id)
          pack=DeliveryPackage.new(:key=>ClassKeyHelper::gen_key("DeliveryPackage"),:parentKey=>dn.key,:packAmount=>packcount,
          :perPackAmount=>t.perPackAmount,:part_rel_id=>t.part_rel_id,:saleNo=>pl.saleNo,:purchaseNo=>pl.purchaseNo,
          :cpartNr=>pl.cpartNr,:spartNr=>pl.spartNr,:remark=>t.remark)
          if t.order_item_id
          pack.order_item_id=t.order_item_id
          pack.orderNr=t.orderNr
          end
          for i in 0...packcount
            item=DeliveryItem.new(:key=>ClassKeyHelper::gen_key("DeliveryItem"),
            :parentKey=>pack.key,:state=>dstate,:wayState=>DeliveryObjWayState::Intransit,:checked=>0,:stored=>0)
            item.save_to_redis
            item.add_to_parent
            t.destroy
            t.delete_from_staff_cache staffId
          end
          pack.save_to_redis
          pack.add_to_parent
        end
      dn.add_to_staff_cache
      dn.save_to_redis
      msg.object=dn.key
      msg.result=true
      else
        msg.content='用户还未选择需要发送的零件'
      end
    else
      msg.content='客户号不存在，请重新填写'
    end
    return msg
  end

  # ws]
  # [功能：] 发送运单
  # 参数：
  # - int : staffId
  # - string : dnKey
  # - string : destiStr
  # - string : sendDate
  # 返回值：
  # - ReturnMsg : JSON
  def self.send_dn  staffId,dnKey,destiStr,sendDate,cusDnnr
    msg=ReturnMsg.new
    if DeliveryNote.exist_in_staff_cache(staffId,dnKey)
      if dn=DeliveryNote.single_or_default(dnKey)
        if dn.items=DeliveryNote.get_children(dn.key,0,-1)[0]
          dn.items.each do |i|
            pl=PartRelInfo.find(i.part_rel_id)
            i.rupdate(:cpartNr=>pl.cpartNr,:spartNr=>pl.spartNr,:saleNo=>pl.saleNo,:purchaseNo=>pl.purchaseNo)
          end
          dn.rupdate(:wayState=>DeliveryObjWayState::Intransit,:destination=>destiStr,:sendDate=>sendDate,:cusDnnr=>cusDnnr)

          dn.delete_from_staff_cache
          dn.add_to_new_queue OrgOperateType::Client
          # DelieveryNote & DeliveryItem 写入Mysql
          Resque.enqueue(DeliveryNoteMysqlRecorder,dn.key)
          #-----
          msg.result=true
          msg.content='运单发送成功'
        else
          msg.content='运单无子项'
        end
      else
        msg.content='运单不存在'
      end
    else
      msg.content='运单已被发送或已取消'
    end
    return msg
  end

  # ws
  # [功能：] 获取运单详细
  # 参数：
  # - int : dtype
  # 返回值：
  # - String : modelName
  def self.delivery_obj_converter dtype
    m=case dtype
    when DeliveryObjType::Note
      "DeliveryNote"
    when DeliveryObjType::Package
      "DeliveryPackage"
    when DeliveryObjType::Item
      "DeliveryItem"
    end
    return m
  end

  def self.delivery_obj_reconverter className
    m=case className
    when  "DeliveryNote"
      DeliveryObjType::Note
    when "DeliveryPackage"
      DeliveryObjType::Package
    when  "DeliveryItem"
      DeliveryObjType::Item
    end
    return m
  end

  # ws
  # [功能：] 取消用户运单
  # 参数：
  # - int : staffId
  # - string : dnKey
  # 返回值：
  # - 无
  def self.cancel_staff_dn staffId,dnKey
    if dn=DeliveryNote.single_or_default(dnKey)
      if dn.staff_id==staffId
        clean_redis_dn_method dn
      end
    end
  end

  def self.clean_redis_dn id
    if dn=DeliveryNote.find(id)
      clean_redis_dn_method dn
    end
  end

  def self.clean_redis_dn_method dn
    if dn.items=DeliveryNote.get_children(dn.key,0,-1)[0]
      dn.items.each do |i|
        if i.items=DeliveryPackage.get_children(i.key,0,-1)[0]
          i.items.each do |ii|
            puts "pack item key:#{ii.key}"
            ii.remove_from_parent
            ii.rdestroy
          end
        end
        puts "pack key:#{i.key}"
        i.remove_from_parent
        i.rdestroy
      end
    dn.rdestroy
    end
  end

  # ws
  # [功能：] 将运单录入Mysql
  # 参数：
  # - string : dnKey
  # 返回值：
  # - 无
  def self.record_dn_into_mysql dnKey
    if dn=DeliveryNote.single_or_default(dnKey)
      if  dn.items=DeliveryNote.get_children(dn.key,0,-1)[0]
        dn.save
        dn.items.each do |p|
          p.delivery_note_id=dn.id
          p.save
          if p.items=DeliveryPackage.get_children(p.key,0,-1)[0]
            p.items.each do |item|
              p.delivery_items.build(:key=>item.key,:parentKey=>item.parentKey).save
            end
          end
        end
      end
    # dn.save
    end
  end

  # ws
  # [功能：] 查询运单
  # 参数：
  # - hash ： 搜索条件
  # - int : startIndex
  # - int : endIndex
  # 返回值：
  # - DeliveryNote : 对象数组
  def self.search_dn condition=nil,orgId,orgOpeType,startIndex,endIndex
    if condition and condition[:queue]
      return DeliveryNote.get_org_dn_queue(orgId,orgOpeType,startIndex,endIndex)
    else
      condi={}
      if orgOpeType==OrgOperateType::Client
        condi[:rece_org_id]=orgId
        if condition and condition[:sender]
          condi[:organisation_id]=[]
          condition[:sender].each do |sender|
            condi[:organisation_id]<<OrganisationRelation.get_partnerid(:oid=>orgId,:pt=>:s,:pnr=>sender)
          end
        end
      elsif orgOpeType==OrgOperateType::Supplier
        condi[:organisation_id]=orgId
        if condition and condition[:receiver]
          condi[:desiOrgId]=[]
          condition[:receiver].each do |receiver|
            condi[:rece_org_id]<<OrganisationRelation.get_partnerid(:oid=>orgId,:pt=>:c,:pnr=>receiver)
          end
        end
      end
      if condition
        condi[:key]=condition[:dnKey] if condition[:dnKey]
        condi[:wayState]=condition[:wayState] if condition[:wayState]
        condi[:state]=condition[:objState] if condition[:objState]
        condi[:sendDate]=(condition[:date]["0"][0]..condition[:date]["0"][1]) if condition[:date]
      end
      total= DeliveryNote.where(condi).count
      return DeliveryNote.limit(endIndex-startIndex+1).offset(startIndex).all(:conditions=>condi),total
    end
  end

  # [功能：] 获取全部公司角色需操作运单
  # 参数：
  # - int ： orgId
  # - int : role
  # 返回值：
  # - DeliveryNote : 对象数组
  def self.get_all_org_role_dn orgId,role
    return DeliveryNote.all_org_role_dn(orgId,role)
  end

  def self.generate_label_pdf params,staff_id
    type=params[:printType].to_i
    case type
    when OrgRelPrinterType::DNPrecheckPrinter
      return generate_pre_dn_check_label_pdf type,staff_id
    else
    return generate_dn_label_pdf type,params[:dnKey],params[:destination],params[:sendDate],params[:cusDnnr]
    end
  end

  # ws
  # [功能：] 生成运单标签PDF文件
  # 参数：
  # - string : dnKey
  # - string : destination
  # - string : sendDate
  # 返回值：
  # - string : fileName
  def self.generate_dn_label_pdf type,dnKey,destination=nil,sendDate=nil,cusDnnr=nil
    msg=ReturnMsg.new
    if dn=DeliveryNote.single_or_default(dnKey)
      if !destination.nil?
        if dn.wayState.nil?
          dn.rupdate(:destination=>destination,:sendDate=>sendDate,:cusDnnr=>cusDnnr)
        end
      end
      msg=TPrinter.print_dn_pdf(type,dnKey)
    else
      msg.content="运单不存在"
    end
    return msg
  end

  # ws
  def self.generate_pre_dn_check_label_pdf type,staff_id
    return TPrinter.print_pre_dn_check_pdf(type,staff_id)
  end

  # ws
  # [功能：] 根据运单号获取清单
  # 参数：
  # - string : dnKey
  # 返回值：
  # - array : delivery items
  def self.get_dn_list dnKey,redis=true,ditKeys=nil
    redis=DeliveryNote.rexists(dnKey) if redis
    if redis
      items=[]
      if dn=DeliveryNote.single_or_default(dnKey)
        if ditKeys
          ditKeys.each do |k|
            if item=DeliveryItem.single_or_default(k)
              p=DeliveryPackage.single_or_default(item.parentKey)
              item.instance_variable_set('@attributes',item.attributes.merge({'cpartNr'=>p.cpartNr,
                'spartNr'=>p.spartNr,
                'parentKey'=>p.parentKey,
                'orderNr'=>p.orderNr,
                'cusDnnr'=>dn.cusDnnr,
                'perPackAmount'=>p.perPackAmount,
                'part_rel_id'=>p.part_rel_id}))
            items<<item
            end
          end
        else
          packs=DeliveryNote.get_children(dn.key,0,-1)[0]
          packs.each do |p|
            p.items=DeliveryPackage.get_children(p.key,0,-1)[0]
            p.items.each do |item|
              item.instance_variable_set('@attributes',item.attributes.merge({'cpartNr'=>p.cpartNr,
                'spartNr'=>p.spartNr,
                'parentKey'=>p.parentKey,
                'orderNr'=>p.orderNr,
                'cusDnnr'=>dn.cusDnnr,
                'perPackAmount'=>p.perPackAmount,
                'part_rel_id'=>p.part_rel_id}))
              items<<item
            end
          end
        end
      end
    return items
    else
      select="delivery_items.*,delivery_packages.cpartNr,delivery_packages.spartNr,delivery_packages.perPackAmount,delivery_packages.part_rel_id"
      condi={}
      condi["delivery_notes.key"]=dnKey
      condi["delivery_items.key"]=ditKeys if ditKeys
      return DeliveryItem.joins(:delivery_package=>:delivery_note).find(:all,:select=>select,:conditions=>condi)
    end
  end

  def self.get_dn_packinfos dnKey,redis=true
    redis=DeliveryNote.rexists(dnKey) if redis
    if redis
      items=nil
      if dn=DeliveryNote.single_or_default(dnKey)
        items=[]
        dn.items=DeliveryNote.get_children(dn.key,0,-1)[0]
        dn.items.each do |p|
          items<<p
        end
      end
    return items
    else
      condi={}
      condi["delivery_notes.key"]=dnKey
      return DeliveryPackage.joins(:delivery_note).find(:all,:conditions=>condi)
    end
  end

  # ws
  # [功能：] 获取运单详细
  # 参数：
  # - DeliveryBaseKey : key
  # - int : startIndex
  # - int : endIndex
  # 返回值：
  # - DeliveryNote.childernCount : 实例对象,子总数
  def self.get_delivery_detail dnKey,startIndex,endIndex,redis=true
    redis=DeliveryNote.rexists(dnKey) if redis
    count=items=nil
    if redis
      if result=(DeliveryNote.get_children dnKey,startIndex,endIndex)
      items=result[0]
      count=result[1]
      end
    else
      condi={}
      condi["delivery_notes.key"]=dnKey
      count=DeliveryPackage.joins(:delivery_note).count(:conditions=>condi)
      items=DeliveryPackage.joins(:delivery_note).limit(endIndex-startIndex+1).offset(startIndex).find(:all, :conditions=>condi) if count>0
    end
    return items,count
  end

  # ws
  # [功能：] 根据运单id获取异常运单
  # 参数：
  # - integer : id
  # 返回值：
  # - array : delivery items
  def self.get_dn_abnormal_pack id
    select="delivery_items.*,delivery_packages.perPackAmount,delivery_packages.packAmount,delivery_packages.cpartNr,delivery_packages.spartNr"
    return DeliveryItem.joins(:delivery_package=>:delivery_note)
    .where("(delivery_items.state=? or delivery_items.wayState in (?)) and delivery_notes.id=?",DeliveryObjState::Abnormal,DeliveryItem.abnormal_waystate,id)
    .select(select).all
  end

  def self.get_pack_by_batch_id id
    select="delivery_items.*,delivery_packages.perPackAmount,delivery_packages.packAmount,delivery_packages.cpartNr,delivery_packages.spartNr"
    return DeliveryItem.joins(:delivery_package).where("delivery_packages.id=?",id).select(select).all
  end

  # ws
  # [功能：] 根据运单需要质检或不要质检的包装箱
  # 参数：
  # - string : dnKey
  # 返回值：
  # - array : delivery items
  def self.get_dn_check_list_from_mysql params
    select="delivery_items.*,delivery_packages.perPackAmount,delivery_packages.packAmount,delivery_packages.cpartNr,delivery_packages.spartNr,strategies.needCheck"
    condi={}
    condi["delivery_notes.key"]=params[:dnKey]
    if !params[:needCheck].nil?
      condi["strategies.needCheck"]=if params[:needCheck]
        [DeliveryObjInspect::SamInspect,DeliveryObjInspect::FullInspect]
      else
        DeliveryObjInspect::ExemInspect
      end
    end
    return DeliveryItem.joins(:delivery_package=>{:part_rel=>:strategy}).joins(:delivery_package=>:delivery_note).find(:all,:select=>select,:conditions=>condi)
  end

  # ws
  # [功能：] 获取包装箱
  # 参数：
  # - integer : id
  # 返回值：
  # - object : delivery item
  def self.get_dn_instore_item id
    select= "delivery_items.*,delivery_packages.perPackAmount as 'amount',part_rels.client_part_id as 'part_id',delivery_packages.part_rel_id"
    return DeliveryItem.joins(:delivery_package=>:part_rel).find(:first,:select=>select,:conditions=>{:id=>id,:stored=>false})
  end

  # ws
  # [功能：] 接收运单
  # 参数：
  # - ids : 包装箱号
  # - dn : 运单
  # - type : 接收/拒收
  # 返回值：
  # - 无
  def self.delivery_item_accept ids,dn_id,type
    begin
      attrs={:wayState=>type}
      delivery_item_update_all(100,ids,attrs)
      dn=DeliveryNote.find(dn_id)
      if type==DeliveryObjWayState::Rejected
        if dn.state==DeliveryObjState::Normal
          dn.update_attributes(:state=>DeliveryObjState::Abnormal,:wayState=>DeliveryObjWayState::InAccept)
        end
        total=dn.delivery_packages.sum('packAmount')
        rejected=dn.delivery_items.where(:wayState=>DeliveryObjWayState::Rejected).count
        if total==rejected
          dn.update_attributes(:wayState=>DeliveryObjWayState::Rejected)
        else
          rece_reje=dn.delivery_items.where(:wayState=>[DeliveryObjWayState::Rejected,DeliveryObjWayState::Received]).count
          if total==rece_reje
            dn.update_attributes(:wayState=>DeliveryObjWayState::Received)
          end
        end
      elsif type==DeliveryObjWayState::Received
        ids.each do |id|
          item=get_dn_instore_item id
          pinfo=PartRelInfo.find(item.part_rel_id)
          WarehouseBll.dn_item_in_by_posiId(pinfo.position_id,item.amount,item.part_id,item.id)
        end
        if dn.wayState==DeliveryObjWayState::Intransit or  dn.wayState==DeliveryObjWayState::Arrived
          dn.update_attributes(:wayState=>DeliveryObjWayState::InAccept)
        end
        if dn.delivery_packages.sum('packAmount')==dn.delivery_items.where(:wayState=>[DeliveryObjWayState::Rejected,DeliveryObjWayState::Received]).count
          dn.update_attributes(:wayState=>DeliveryObjWayState::Received)
        end
      end
    rescue Exception=>e
      puts e.message
      puts e.backtrace
    end
  end

  # ws
  # [功能：] 接收运单
  # 参数：
  # - ids : 包装箱号
  # - dn : 运单
  # - type : 接收/拒收
  # 返回值：
  # - 无
  def self.delivery_item_inspect type,ids,dn_id,attrs,state
    DeliveryItemState.where(:delivery_item_id=>ids).update_all(state)
    delivery_item_update_all 100,ids,attrs
    Resque.enqueue(DeliveryNoteWayStateRoleMachine,dn_id,DeliveryRoleMachineAction::DoInspect)
  end

  # ws
  # [功能：] 包装箱退货
  # 参数：
  # - ids : 包装箱号
  # - dn : 运单
  # 返回值：
  # - 无
  def self.delivery_item_return ids,dn_id
    dn=DeliveryNote.find(dn_id)
    delivery_item_update_all(100,ids,{:checked=>true,:state=>DeliveryObjState::Abnormal,:wayState=>DeliveryObjWayState::Returned})
    if dn.delivery_packages.sum('packAmount')==dn.delivery_items.where(:wayState=>[DeliveryObjWayState::Returned]).count
      dn.update_attributes(:wayState=>DeliveryObjWayState::Returned)
    end
  end

  def self.delivery_note_wayState_state_update id,ids=nil
    dn=DeliveryNote.find(id)
    if dn
      case dn.wayState
      when DeliveryObjWayState::Arrived
        dn.delivery_items.update_all(:wayState=>DeliveryObjWayState::InAccept)
        delivery_item_update_all 300,dn.key,{:wayState=>DeliveryObjWayState::InAccept}
      when DeliveryObjWayState::Returned
        dn.delivery_items.update_all(:wayState=>DeliveryObjWayState::Returned)
        delivery_item_update_all 300,dn.key,{:wayState=>DeliveryObjWayState::Returned}
      end
    end
  end

  # ws
  # [功能：] 更新包装箱状态，同时更新redis数据，保持同步
  # 参数：
  # - integer : 更新类型，用以判断id或key
  # - ids : 包装箱id或key
  # - attrs : 需要更新的属性
  # 返回值：
  # - array : delivery items
  def self.delivery_item_update_all type,index,attrs
    if type==100
      DeliveryItem.where(:id=>index).update_all(attrs)
      DeliveryItem.where(:id=>index).all.each do |item|
        item.rupdate(attrs)
      end
    elsif type==200
      index.each do |key|
        if item=DeliveryItem.single_or_default(key)
        item.rupdate(attrs)
        end
      end
    elsif type==300
      get_dn_list(index).each do |item|
        item.rupdate(attrs)
      end
    end
  end

  def self.dn_arrive msg,dn,orgId,ids=nil
    if msg.result
      if dn.rece_org_id==orgId
        if dn.wayState==DeliveryObjWayState::Intransit
          dn.update_attributes(:wayState=>DeliveryObjWayState::Arrived)
          Resque.enqueue(DeliveryNoteWayStateStateUpdater,dn.id)
          msg=set_way_state_code(msg,DeliveryObjWayState::InAccept)
        else
          msg.result=false
          msg.content="运单：#{DeliveryObjWayState.get_desc_by_value(dn.wayState)}，不可再次到达"
        end
      else
        msg.result=false
        msg.content="无权限操作本运单"
      end
    end
    return msg
  end

  def self.set_way_state_code msg,code
    msg.instance_variable_set "@wayState",DeliveryObjWayState.get_desc_by_value(code)
    msg.instance_variable_set "@wayStateCode",code
    return msg
  end
end
