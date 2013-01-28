#encoding: utf-8
module Api
  class AuthController<AppController
    def login
      msg=ReturnMsg.new
      if staff=Staff.authenticate(params[:staffNr], params[:password])
        msg.result=true
        org=staff.organisation
        msg.object={:staffNr=>staff.staffNr,:staffName=>staff.name,:staffId=>staff.id,
          :orgId=>org.id,:orgName=>org.name}
      end
      render :json=> msg
    end
  end
end