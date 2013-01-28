#encoding: utf-8
class SessionsController < ApplicationController

  layout "login"
  def new
  end

  def create
    if staff = Staff.authenticate( params[:staffNr], params[:password] )
      session[:staff_id] = staff.id
      session[:org_id] = staff.orgId
      #   session[:orgOpeType]=OrgOperateType::Client
      render :json=>{ :status=>1 }
    else
      render :json=>{ :status=>0 }
    end

  end

  def destroy
    session[:staff_id] = nil
    session[:org_id] = nil
    session[:orgOpeType] = nil
    redirect_to login_url, :notice => "已注销"
  end

  def reload
      if params[:t].to_i==OrgOperateType::Client 
        session[:orgOpeType]=  OrgOperateType::Client 
        redirect_to :controller=>:demander,:action =>:demand_upload
      elsif params[:t].to_i==OrgOperateType::Supplier
        session[:orgOpeType]= OrgOperateType::Supplier
        redirect_to :controller=>:demander,:action =>:index
      else
          redirect_to login_url,:notice=>'请重新登录'
      end
  end

end
