#encoding: utf-8
require 'org_rel_info'

module Api
  class DeliveryController<AppController
    before_filter :delivery_auth,:only=>[:arrive]
    
    def print_queue_list
      render :json=>DeliveryNote.get_all_print_dnKey(params[:staffId])
    end

    def remove_from_print_queue
      msg=ReturnMsg.new
      if dn=DeliveryNote.single_or_default(params[:dnKey])
        if msg.result=dn.del_from_staff_print_queue
          msg.content="删除成功"
        else
          msg.content="运单已从打印队列中删除"
        end
      end
      render :json=>msg
    end

    def package_list
      items=[]
      if dn=DeliveryNote.single_or_default(params[:dnKey])
        items=DeliveryNote.get_children(dn.key,0,-1)[0]
      end
      render :json=>items
    end

    def item_list
      items=DeliveryBll.get_dn_list params[:dnKey]
      render :json=>items
    end

    def item_print_data
      diKeys=params[:diKeys].split(',') if params[:diKeys]
      type=params[:type].to_i
      dnKey=nil
      ddn=nil
      msg=ReturnMsg.new
      begin
        if diKeys
          if item=DeliveryItem.single_or_default(diKeys[0])
            pack=DeliveryPackage.single_or_default(item.parentKey)
            ddn=DeliveryNote.single_or_default(pack.parentKey)
          end
        else
          dnKey=params[:dnKey]
        end
        if dn=ddn||DeliveryNote.single_or_default(dnKey)
          printer,dataset=TPrinter.generate_dn_item_print_data(dn.key,type,diKeys)
          msg.result=true
          msg.instance_variable_set :@template,printer.template
          msg.instance_variable_set :@dataset,dataset
        end
      rescue DataMissingError=>e
        msg.content=e.message
      rescue NoMethodError=>e
        msg.content="打印机模板未设置，联系系统供应商进行设置"
      rescue Exception=>e
        puts e.message
        puts e.backtrace
        msg.content="打印服务错误，请联系系统供应商"
      end
      render :json=> msg
    end

    def updated_template
      templates=[]
      orgId=params[:orgId]
      OrganisationRelation.where(:origin_supplier_id=>orgId).each do |orgrel|
        OrgRelPrinter::CLIENT_PACK_TEMPLATE.each do |type|
          if printer=OrgRelPrinter.get_default_printer(orgrel.id,type) and printer.updated="true"
            templates<<printer.template
            printer.update(:updated=>false)
          end
        end
      end
      render :json=>templates
    end

    def client_pack_template
      templates=[]
      OrgRelPrinter::CLIENT_PACK_TEMPLATE.each do |v|
        templates<<{:desc=>OrgRelPrinterType.get_desc_by_value(v),:value=>v}
      end
      render :json=>templates
    end
    
    def arrive
      puts Base64.decode64(request.headers["Authorization"])
      render :json=>DeliveryBll.dn_arrive(@msg,@dn,params[:org_id].to_i)
    end
    
  end
end