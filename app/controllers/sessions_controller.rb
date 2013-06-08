#encoding: utf-8
class SessionsController < ApplicationController

  layout "login"
  def new
  end

  # [功能：] 用户登录。
  def create
    if staff = Staff.authenticate( params[:staffNr], params[:password] )
      session[:staff_id] = staff.id
      # session[:org_id] = staff.orgId
      session[:org_id]=staff.organisation_id
      #   session[:orgOpeType]=OrgOperateType::Client
      render :json=>{ :status=>1 }
    else
      render :json=>{ :status=>0 }
    end

  end
  
  # [功能：] 注销。
  def destroy
    reset_session
    redirect_to login_url, :notice => "已注销"
  end

end
