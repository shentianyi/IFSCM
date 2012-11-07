#coding:utf-8
class WelmanController < ApplicationController

  before_filter  :authorize
  
  def index
    session[:orgOpeType]=nil
  end
  
end
