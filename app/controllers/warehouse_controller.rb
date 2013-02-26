#encoding: utf-8
class WarehouseController < ApplicationController
  
  before_filter  :authorize
  
  def stock_out_list
    begin
      raise( ArgumentError, "格式错误：仓库ID！" )  unless params[:whId].is_a?(String)
      raise( ArgumentError, "格式错误：零件号！" )  unless params[:partNr].is_a?(String)
      warehouseId = params[:whId].strip
      partNr = params[:partNr].strip
      raise( ArgumentError, "参数错误：仓库ID无效！" )  unless FormatHelper.str_is_positive_integer( warehouseId )
      raise( RuntimeError, "仓库不存在！" )  unless wh = @cz_org.warehouses.find_by_id(warehouseId)
      posis = wh.positions.by_part(partNr)
      if posis.present?
        @whid = warehouseId
        @posilist = posis
        render :partial => "stock_out_list"
      else
        render :text => "没有找到相关库位！"
      end
    rescue Exception => e
      render :text => e.to_s
    end
  end
  
  def stock_out
    if request.get?
    else
      begin
        raise( ArgumentError, "格式错误：库位ID！" )  unless params[:posiId].is_a?(String)
        raise( ArgumentError, "格式错误：出库量！" )  unless params[:amount].is_a?(String)
        posiId = params[:posiId].strip
        amount = params[:amount].strip
        raise( ArgumentError, "参数错误：库位ID无效！" )  unless FormatHelper.str_is_positive_integer( posiId )
        raise( ArgumentError, "参数错误：出库量无效！" )  unless FormatHelper.str_is_positive_float( amount )
        msg = WarehouseBll.position_out( posiId.to_i, amount.to_f )
        if msg.result
          render :json => {:flag=>true, :msg=>"出库成功。"}
        else
          render :json => {:flag=>false, :msg=>msg.content}
        end
      rescue Exception => e
        render :json => {:flag=>false, :msg=>e.to_s}
      end
    end
  end
  
  def primary_warehouse
    if request.get?
      @warehouses = @cz_org.warehouses
    else
      begin
        raise( ArgumentError, "格式错误：仓库编号！" )  unless params[:whNr].is_a?(String)
        raise( ArgumentError, "格式错误：仓库名称！" )  unless params[:whName].is_a?(String)
        whNr = params[:whNr].strip
        whName = params[:whName].strip
        raise( RuntimeError, "仓库已存在，不可重建！" )  if @cz_org.warehouses.where( :nr=>whNr ).first
        wh = Warehouse.new( :nr=>whNr, :name=>whName )
        if @cz_org.warehouses << wh
          @warehouses = @cz_org.warehouses
          render :json => {:flag=>true, :msg=>"新建仓库成功。", :txt=>render_to_string(:partial=>"warehouses_list") }
        else
          render :json => {:flag=>false, :msg=>"失败！"}
        end
      rescue Exception => e
        render :json => {:flag=>false, :msg=>e.to_s}
      end
    end
  end
  
  def delete_warehouse
    begin
      raise( ArgumentError, "格式错误：仓库ID！" )  unless params[:whId].is_a?(String)
      whId = params[:whId].strip
      raise( RuntimeError, "仓库不存在！" )  unless wh = @cz_org.warehouses.find_by_id(whId)
      raise( RuntimeError, "不可删除，必须先删除其所有库位！" )  if wh.positions.present?
      if wh.destroy
        @warehouses = @cz_org.warehouses
        render :json => {:flag=>true, :msg=>"删除仓库成功。", :txt=>render_to_string(:partial=>"warehouses_list") }
      else
        render :json => {:flag=>false, :msg=>"失败！"}
      end
    rescue Exception => e
      render :json => {:flag=>false, :msg=>e.to_s}
    end
  end
  
  def primary_position
    if request.get?
      begin
        raise( ArgumentError, "格式错误：仓库ID！" )  unless params[:whId].is_a?(String)
        whId = params[:whId].strip
        raise( ArgumentError, "参数错误：仓库ID无效！" )  unless FormatHelper.str_is_positive_integer( whId )
        if wh = Warehouse.find_by_id(whId)
          @whid = whId
          @positions = wh.positions
          render :partial => "positions_list"
        else
          render :text => "没有找到相关库位！"
        end
      rescue Exception => e
        render :text => e.to_s
      end
    else
      begin
        raise( ArgumentError, "格式错误：仓库ID！" )  unless params[:whId].is_a?(String)
        raise( ArgumentError, "格式错误：库位编号！" )  unless params[:posiNr].is_a?(String)
        raise( ArgumentError, "格式错误：库位容量！" )  unless params[:capacity].is_a?(String)
        whId = params[:whId].strip
        posiNr = params[:posiNr].strip
        capacity = params[:capacity].strip
        raise( ArgumentError, "参数错误：仓库ID无效！" )  unless FormatHelper.str_is_positive_integer( whId )
        raise( ArgumentError, "参数错误：容量无效！" )  unless FormatHelper.str_is_positive_integer( capacity )
        raise( RuntimeError, "仓库不存在！" )  unless wh = @cz_org.warehouses.find_by_id(whId)
        raise( RuntimeError, "库位已存在，不可重建！" )  if wh.positions.where( :nr=>posiNr ).first
        posi = Position.new( :nr=>posiNr, :capacity=>capacity )
        if wh.positions << posi
          @whid = whId
          @positions = wh.positions
          render :json => {:flag=>true, :msg=>"新建库位成功。", :txt=>render_to_string(:partial=>"positions_list") }
        else
          render :json => {:flag=>false, :msg=>"失败！"}
        end
      rescue Exception => e
        render :json => {:flag=>false, :msg=>e.to_s}
      end
    end
  end
  
  def delete_position
    begin
      raise( ArgumentError, "格式错误：库位ID！" )  unless params[:posiId].is_a?(String)
      posiId = params[:posiId].strip
      raise( RuntimeError, "库位不存在！" )  unless posi = Position.find_by_id(posiId)
      raise( RuntimeError, "无权删除！" )  if posi.warehouse.organisation != @cz_org
      raise( RuntimeError, "不可删除，必须先清空其所有库存量！" )  if posi.stock>0
      if posi.destroy
        @whid = posi.warehouse.id
        @positions = posi.warehouse.positions
        render :json => {:flag=>true, :msg=>"删除库位成功。", :txt=>render_to_string(:partial=>"positions_list") }
      else
        render :json => {:flag=>false, :msg=>"失败！"}
      end
    rescue Exception => e
      render :json => {:flag=>false, :msg=>e.to_s}
    end
  end
  
end
