#encoding: utf-8
class StaffController < ApplicationController
  
  before_filter  :authorize
  
  def index
    @staff = Staff.find(session[:staff_id])
  end
  
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
