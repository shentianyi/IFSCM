#encoding: utf-8
require 'org_rel_info'
module Api
  class DeliveryController<AppController
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
      if dn=DeliveryNote.single_or_default(params[:dnKey])
        dn.items=DeliveryNote.get_children(dn.key,0,-1)[0]
      end
      render :json=>dn.items
    end

    def item_list
      items=[]
      if dn=DeliveryNote.single_or_default(params[:dnKey])
        dn.items=DeliveryNote.get_children(dn.key,0,-1)[0]
        dn.items.each do |pack|
          pack.items=DeliveryPackage.get_children(pack.key,0,-1)[0]
          pack.items.each do |item|
            i=Class.new
            i.instance_variable_set :@key,item.key
            i.instance_variable_set :@cpartNr,pack.cpartNr
            i.instance_variable_set :@spartNr,pack.spartNr
            i.instance_variable_set :@perPackAmount,pack.perPackAmount
            items<<i
          end
        end
      end
      render :json=>items
    end

    def item_print_data
      diKeys=params[:diKeys].split(',') if params[:diKeys]
      dnKey=nil
      ddn=nil
      if diKeys
        if item=DeliveryItem.single_or_default(diKeys[0])
          pack=DeliveryPackage.single_or_default(item.parentKey)
          ddn=DeliveryNote.single_or_default(pack.parentKey)
        end
      else
        dnKey=params[:dnKey]
      end
      data=nil
      if dn=ddn||DeliveryNote.single_or_default(dnKey)        
        printer,dataset=TPrinter.generate_dn_item_print_data(dn.key,diKeys)
        data=Class.new
        data.instance_variable_set :@template,printer.template
        data.instance_variable_set :@dataset,dataset
      end
      render :json=>data
    end
    
    def updated_template
      templates=[]
      orgId=params[:orgId]
      OrganisationRelation.where(:origin_supplier_id=>orgId).each do |orgrel|
        [OrgRelPrinterType::DNPrinter,OrgRelPrinterType::DPackPrinter].each do |type|
          if printer=OrgRelPrinter.get_default_printer(orgrel.id,type) and printer.updated="true"         
              templates<<printer.template
              printer.update(:updated=>false)           
          end
        end
      end
      puts templates.to_json
      render :json=>templates
    end
    
    
  end
end