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
        if pr.organisation_relation_id!=PartRel.find(dit.partRelId).organisation_relation_id
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
    ids = temps.collect {|t| PartRel.find_by_id(t.partRelId.to_i).organisation_relation_id}
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
  def self.build_delivery_note staffId,orgId,desiOrgNr
    msg=ReturnMsg.new
    if desiOrgId=OrganisationRelation.get_partnerid(:oid=>orgId,:pt=>:c,:pnr=>desiOrgNr)
      #get di temps
      if temps=DeliveryItemTemp.get_staff_cache(staffId)[0]
        #new delivery note
        dstate=DeliveryObjState::Normal
        dn=DeliveryNote.new(:key=>ClassKeyHelper::gen_key("DeliveryNote"),:state=>dstate,:staff_id=>staffId,:organisation_id=>orgId,:rece_org_id=>desiOrgId)
        temps.each do |t|
          packcount=t.packAmount
          pl=PartRel.find(t.partRelId)
          pack=DeliveryPackage.new(:key=>ClassKeyHelper::gen_key("DeliveryPackage"),:parentKey=>dn.key,:packAmount=>packcount,
          :perPackAmount=>t.perPackAmount,:partRelId=>t.partRelId,:saleNo=>pl.saleNo,:purchaseNo=>pl.purchaseNo,
          :cpartNr=>Part.get_partNr(desiOrgId,pl.client_part_id),:spartNr=>Part.get_partNr(orgId,pl.supplier_part_id))
          for i in 0...packcount
            item=DeliveryItem.new(:key=>ClassKeyHelper::gen_key("DeliveryItem"),:parentKey=>pack.key,:state=>dstate)
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

  # ws
  # [功能：] 获取运单详细
  # 参数：
  # - DeliveryBaseKey : key
  # - int : startIndex
  # - int : endIndex
  # 返回值：
  # - DeliveryNote.childernCount : 实例对象,子总数
  def self.get_delivery_detail key,startIndex,endIndex
    if result=(DeliveryNote.get_children key,startIndex,endIndex)
    return result[0],result[1]
    end
    return nil
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
  def self.send_dn  staffId,dnKey,destiStr,sendDate
    msg=ReturnMsg.new
    if DeliveryNote.exist_in_staff_cache(staffId,dnKey)
      if dn=DeliveryNote.single_or_default(dnKey)
        if dn.items=DeliveryNote.get_children(dn.key,0,-1)[0]
          dn.items.each do |i|
            pl=PartRel.find(i.partRelId)
            i.rupdate(:cpartNr=>Part.get_partNr(dn.rece_org_id,pl.client_part_id),
            :spartNr=>Part.get_partNr(dn.organisation_id,pl.supplier_part_id),:saleNo=>pl.saleNo,:purchaseNo=>pl.purchaseNo)
          end
          dn.rupdate(:wayState=>DeliveryNoteWayState::Intransit,:destination=>destiStr,:sendDate=>sendDate)
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
      if dn.staff_id.to_i==staffId
        # dn.get_children 0,-1
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
        dn.items.each do |p|
          p.save
          if p.items=DeliveryPackage.get_children(p.key,0,-1)[0]
            p.items.each do |item|
              p.delivery_items.build(:key=>item.key,:state=>item.state,:parentKey=>item.parentKey).save
            end
          end
        end
      end
    dn.save
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

  # ws
  # [功能：] 生成运单标签PDF文件
  # 参数：
  # - string : dnKey
  # - string : destination
  # - string : sendDate
  # 返回值：
  # - string : fileName
  def self.generate_dn_label_pdf dnKey,destination,sendDate
    fileName=nil
    if dn=DeliveryNote.single_or_default(dnKey)
      if dn.wayState.nil?
        dn.rupdate(:destination=>destination,:sendDate=>sendDate)
      end
      result=TPrinter.print_dn_pdf(dnKey)
      if result[:result]
        fileName=result[:content]
      end
    end
    return fileName
  end

  # ws
  # [功能：] 生成运单包装箱标签PDF文件
  # 参数：
  # - string : dnKey
  # 返回值：
  # - string : fileName
  def self.generate_dn_pack_label_pdf dnKey
    fileName=nil
    if dn=DeliveryNote.single_or_default(dnKey)
      dn.items=DeliveryBase.get_children dn.key,0,-1
      result=Wcfer::PdfPrinter.generate_dn_pack_pdf dn.items.to_json
      if result[:result]
        fileName=result[:content]
      end
    end
    return fileName
  end

end
