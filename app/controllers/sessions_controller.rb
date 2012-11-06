#coding:utf-8
require 'enum/org_operate_type'
class SessionsController < ApplicationController

  layout "login"

  def new
  end

  def create
    if staff = Staff.authenticate( params[:staffNr], params[:password] )
          session[:staff_id] = staff.id
          session[:org_id] = staff.orgId
       #   session[:orgOpeType]=OrgOperateType::Client
          redirect_to :controller=>'welman',action: 'index'
    else
          redirect_to login_url, :notice => "用户名或密码错误"
    end

  end

  def destroy
        session[:staff_id] = nil
        redirect_to login_url, :notice => "注销"
  end
  
  def change_ope_type
    if session[:orgOpeType]
      session[:orgOpeType]= session[:orgOpeType]==OrgOperateType::Client ? OrgOperateType::Supplier : OrgOperateType::Client
    else
      redirect_to login_url,:notice=>'请重新登录'
    end
  end
  
end
