#coding:utf-8

module DeliveryHelper
  # ws
  # [功能：] 验证包装箱数和单位数量是否合法
  # 参数：
  # - string : metaKey
  # - string : packAmount
  # - string : perPackAmount
  # 返回值：
  # - ValidMsg : 验证消息
  def self.vali_di_temp metaKey,packAmount,perPackAmount
    msg=ValidMsg.new(:result=>true,:content_key=>Array.new)
    # vali partRelMetaKey
    if !PartRelMeta.find(metaKey)
      msg.result=false
      msg.content_key<<:partRelMetaNotEx
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

  # ws
  # [功能：] 生成运单
  # 参数：
  # - int : staffId
  # - int : orgId
  # - string : desiOrgNr
  # 返回值：
  # - ReturnMsg : JSON
  def self.build_delivery_note staffId,orgId,desiOrgNr
    msg=ReturnMsg.new(:result=>false,:content=>'')
    if desiOrgId=Organisation.find_by_id(orgId).get_parterId_by_parterNr(OrgOperateType::Supplier,desiOrgNr)
      #get di temps
      if temps=DeliveryItemTemp.get_all_staff_cache(staffId)
        #new delivery note
        dstate=DeliveryObjState::Normal
        dn=DeliveryNote.new(:type=>DeliveryObjType::Note,
        :state=>dstate,:sender=>staffId,:orgId=>orgId,:desiOrgId=>desiOrgId)
        temps.each do |t|
          packcount=t.packAmount
          for i in 0...packcount
            # pack=DeliveryPackage.new(:type=>DeliveryObjType::Package,:parentKey=>dn.key,:state=>dstate)
            item=DeliveryItem.new(:type=>DeliveryObjType::Item,:parentKey=>dn.key,:amount=>t.perPackAmount,:partRelMetaKey=>t.partRelMetaKey,:state=>dstate)
            item.save
            item.add_to_parent
            # pack.save
            # pack.add_to_parent
            t.destroy
            t.delete_from_staff_cache staffId
          end
        end
      dn.add_to_staff_cache staffId
      dn.save
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

  # ws
  # [功能：] 获取运单详细
  # 参数：
  # - DeliveryNote : dn
  # - int : startIndex
  # - int : endIndex
  # 返回值：
  # - DeliveryNote.childernCount : 实例对象,子总数
  def self.get_dn_detail dn,startIndex,endIndex
    if total=(dn.get_children startIndex,endIndex)
    return dn,total
    end
    return nil
  end

  # ws]
  # [功能：] 发送运单
  # 参数：
  # - int : staffId
  # - string : dnKey
  # - string : destiStr
  # 返回值：
  # - ReturnMsg : JSON
  def self.send_dn  staffId,dnKey,destiStr
    msg=ReturnMsg.new(:result=>false,:content=>'')
    if DeliveryNote.exist_in_staff_cache(staffId,dnKey)
      if dn=DeliveryNote.find(dnKey)
        if dn.get_children 0,-1
          dn.items.each do |i|
            prm=PartRelMeta.find(i.partRelMetaKey)
            i.update(:cpartNr=>Part.find(prm.cpartId).partNr,:spartNr=>Part.find(prm.spartId).partNr,:saleNo=>prm.saleNo,:purchaseNo=>prm.purchaseNo)
          end
          dn.update(:wayState=>DeliveryNoteWayState::Intransit,:destination=>destiStr)
          dn.add_to_orgs
          dn.delete_from_staff_cache
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

  # ws
  # [功能：] 取消用户运单
  # 参数：
  # - int : staffId
  # - string : dnKey
  # 返回值：
  # - 无
  def self.cancel_staff_dn staffId,dnKey
    if dn=DeliveryNote.find(dnKey)
      if dn.sender.to_i==staffId
        dn.get_children 0,-1
        if dn.items
          dn.items.each do |i|
            i.remove_from_parent
            i.destroy
          end
        dn.destroy
        end
      end
    end
  end

  # ws
  # [功能：] 将运单录入Mysql
  # 参数：
  # - string : dnKey
  # 返回值：
  # - 无
  def self.record_dn_into_mysql dnKey
    if dn=DeliveryNote.find(dnKey)
      mdn =MDeliveryNote.new( :desiOrgId=>dn.desiOrgId, :destination=>dn.destination, :key=>dn.key, :orgId=>dn.orgId, :sender=>dn.sender, :state=>dn.state, :wayState=>dn.wayState)
      if dn.get_children 0,-1
        dn.items.each do |i|
          mdn.m_delivery_item.build( :amount=>i.amount, :cpartNr=>i.cpartNr, :key=>i.key, :parentKey=>i.parentKey, :partRelMetaKey=>i.partRelMetaKey,
          :purchaseNo=>i.purchaseNo, :saleNo=>i.saleNo, :spartNr=>i.spartNr, :state=>i.state).save
        end
      end
    mdn.save
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
        condi[:desiOrgId]=orgId
        if condition and condition[:sender]
          org=Organisation.find_by_id(orgId)
          condi[:orgId]=[]
          condition[:sender].each do |sender|
            condi[:orgId]<<org.get_parterId_by_parterNr(orgOpeType,sender)
          end
        end
      elsif orgOpeType==OrgOperateType::Supplier
        condi[:orgId]=orgId
        if condition and condition[:receiver]
          org=Organisation.find_by_id(orgId)
          condi[:desiOrgId]=[]
          condition[:receiver].each do |receiver|
            condi[:desiOrgId]<<org.get_parterId_by_parterNr(orgOpeType,receiver)
          end
        end
      end
      if condition
        condi[:key]=condition[:dnKey] if condition[:dnKey]
        # condi[:orgId]=condition[:sender] if condition[:sender]
        #  condi[:desiOrgId]=condition[:receiver] if condition[:receiver]
        condi[:wayState]=condition[:wayState] if condition[:wayState]
        condi[:state]=condition[:objState] if condition[:objState]
        condi[:created_at]=(condition[:date]["0"][0]..condition[:date]["0"][1]) if condition[:date]
      end
      total= MDeliveryNote.where(condi).count
      return MDeliveryNote.limit(endIndex-startIndex+1).offset(startIndex).all(:conditions=>condi),total
    end
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
  # [功能：] 获得运单项状态
  # 参数：
  # - code : 状态码
  # 返回值：
  # - string : description
  def self.get_delivery_obj_state code
    DeliveryObjState.get_desc_by_value code
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
end
