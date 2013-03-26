#encoding: utf-8
module Api
  class AppController<ActionController::Base
    skip_before_filter :verify_authenticity_token
    
    def delivery_auth
      if params[:dnKey]
        @dn=DeliveryNote.single_or_default(params[:dnKey],true)
        private_delivery_auth
      end
    end
    
    private
    def private_delivery_auth
      @msg=ReturnMsg.new
      if @dn
        if @dn.organisation_id==params[:org_id].to_i or @dn.rece_org_id==params[:org_id].to_i
        @msg.result=true
        else
          @msg.content='此运单无权限查看'
        end
      else
        @msg.content='运单不存在'
      end
    end
  end
end