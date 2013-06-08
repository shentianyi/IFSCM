#encoding: utf-8
class StaffController < ApplicationController
  
  before_filter  :authorize
  
  # [功能：] 显示用户信息的界面。
  def index
    @staff = Staff.find(session[:staff_id])
  end
  
  # [功能：] 编辑用户信息，更改密码。
  def edit
    if request.get?
      @staff = Staff.find(session[:staff_id])
      render :partial => "edit"
    else
      @staff = Staff.find(session[:staff_id])
      
        if @staff.update_attributes(params[:staff])
            redirect_to user_path, notice: "#{@staff.name}  密码更新成功。"
        end
    end
  end
  
end
