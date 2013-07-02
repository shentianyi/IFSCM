#encoding: utf-8
class WelmanController < ApplicationController

  before_filter  :authorize
  
  def index
    session[:orgOpeType]=nil
  end
  
  # [功能：] 客户的界面。
  def client
    session[:orgOpeType] = OrgOperateType::Client
  end
  
  # [功能：] 供应商的界面。
  def supplier
    session[:orgOpeType] =OrgOperateType::Supplier
  end
  
end
