#encoding: utf-8
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
          items+=pack.items
        end
      end
      render :json=>items
    end
    
    def item_print_data
      printer,dataset=TPrinter.generate_dn_item_print_data(params[:dnKey])
      data=Class.new
      data.instance_variable_set :@template,printer.template
      data.instance_variable_set :@dataset,dataset
      puts "data:#{data.to_json}"
      render :json=>data
    end
  end
end