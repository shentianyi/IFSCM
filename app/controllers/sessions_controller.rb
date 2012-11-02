#coding:utf-8
class SessionsController < ApplicationController


  def new
  end

  def create
    if staff = Staff.authenticate( params[:staffNr], params[:password] )
          session[:staff_id] = staff.id
          session[:org_id] = staff.orgId
          redirect_to demander_index_url
    else
          redirect_to login_url, :notice => "用户名或密码错误"
    end

  end

  def destroy
        session[:staff_id] = nil
        redirect_to login_url, :notice => "注销"

  end
  
end
