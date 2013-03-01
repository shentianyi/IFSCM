#encoding: utf-8
class WelmanController < ApplicationController

  before_filter  :authorize
  
  def index
    session[:orgOpeType]=nil
  end
  
  def client
    session[:orgOpeType] = OrgOperateType::Client
  end
  
  def supplier
    session[:orgOpeType] =OrgOperateType::Supplier
  end
  
end
