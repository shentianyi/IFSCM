#coding:utf-8
require 'enum/org_operate_type'
class ApplicationController < ActionController::Base
  # protect_from_forgery
  
  protected
  def authorize
    unless Staff.find_by_id(session[:staff_id])
      redirect_to login_url, :notice => "请登录"
    end
    @cz_org = Organisation.find_by_id(session[:org_id])
    if session[:orgOpeType]==OrgOperateType::Client
      @isClient=true
    elsif session[:orgOpeType]==OrgOperateType::Supplier
      @isClient=false
    end
  end
  
  # def org_initial
    # @cz_org = Organisation.find_by_id(session[:org_id])
  # end
  
end
