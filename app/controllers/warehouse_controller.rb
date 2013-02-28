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
      @whlist = Warehouse.selection_list(@cz_org)
    else
      begin
        raise( ArgumentError, "格式错误：库位ID！" )  unless params[:posiId].is_a?(String)
        raise( ArgumentError, "格式错误：零件号！" )  unless params[:partNr].is_a?(String)
        raise( ArgumentError, "格式错误：出库量！" )  unless params[:amount].is_a?(String)
        posiId = params[:posiId].strip
        partNr = params[:partNr].strip
        amount = params[:amount].strip
        raise( ArgumentError, "参数错误：库位ID无效！" )  unless FormatHelper.str_is_positive_integer( posiId )
        raise( ArgumentError, "参数错误：出库量无效！" )  unless FormatHelper.str_is_positive_float( amount )
        msg = WarehouseBll.position_out( posiId.to_i, partNr, amount.to_f )
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
        raise( ArgumentError, "格式错误：仓库编号！" )  unless params[:whNr].present? and params[:whNr].is_a?(String)
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
          @positions = wh.positions.order("nr desc")
          @newposi = []
          render :partial => "positions_list"
        else
          render :text => "没有找到相关库位！"
        end
      rescue Exception => e
        render :text => e.to_s
      end
    else
      begin
        raise( ArgumentError, "格式错误：仓库ID！" )  unless params[:whId].is_a?(String) and whId = params[:whId].strip
        raise( RuntimeError, "没有新库位需要添加！" )  unless params[:posiHash].present? and posiHash = params[:posiHash]
        raise( ArgumentError, "参数错误：仓库ID无效！" )  unless FormatHelper.str_is_positive_integer( whId )
        raise( RuntimeError, "仓库不存在！" )  unless wh = @cz_org.warehouses.find_by_id(whId)
        @newposi = []
        posiHash.each do |k,v|
          posi = Position.new( :nr=>k, :capacity=>v )
          posi.errors[:temp]="错误"  unless FormatHelper.str_is_positive_integer( v )
          posi.errors[:temp]="重复"  if posi.errors.blank? and wh.positions.where( :nr=>k ).first
          if posi.errors.blank? and wh.positions << posi
          else
            posi.errors[:temp]="错误"  if posi.errors.blank?
            @newposi << posi
          end
        end
        @whid = whId
        @positions = wh.positions.order("nr desc")
        render :json => {:flag=>true, :msg=>"新建库位成功。", :txt=>render_to_string(:partial=>"positions_list") }
      rescue Exception => e
        render :json => {:flag=>false, :msg=>e.to_s}
      end
    end
  end
  
  def new_position_range
      begin
        raise( ArgumentError, "格式错误：仓库ID！" )  unless params[:whId].is_a?(String) and whId = params[:whId].strip
        raise( ArgumentError, "格式错误：库位起点！" )  unless params[:posiStart].is_a?(String) and posiStart=params[:posiStart].strip and posiStart.present?
        raise( ArgumentError, "格式错误：库位终点！" )  unless params[:posiEnd].is_a?(String) and posiEnd=params[:posiEnd].strip and posiEnd.present?
        raise( ArgumentError, "格式错误：库位容量！" )  unless params[:capa].is_a?(String) and capa=params[:capa].strip
        raise( ArgumentError, "参数错误：仓库ID无效！" )  unless FormatHelper.str_is_positive_integer( whId )
        raise( ArgumentError, "参数错误：容量无效！" )  unless FormatHelper.str_is_positive_integer( capa )
        raise( RuntimeError, "仓库不存在！" )  unless wh = @cz_org.warehouses.find_by_id(whId)
        @whid = whId
        @positions = wh.positions.order("nr desc")
        @newposi = []
        (posiStart..posiEnd).each do |p|
          posi = Position.new( :nr=>p, :capacity=>capa )
          posi.errors[:temp]="重复"  if wh.positions.where( :nr=>p ).first
          @newposi << posi
        end
          render :json => {:flag=>true, :msg=>"新建库位成功。", :txt=>render_to_string(:partial=>"positions_list") }
      rescue Exception => e
        render :json => {:flag=>false, :msg=>e.to_s}
      end
  end
  
  def new_position_single
      begin
        raise( ArgumentError, "格式错误：仓库ID！" )  unless params[:whId].is_a?(String) and whId = params[:whId].strip
        raise( ArgumentError, "格式错误：库位！" )  unless params[:posiNr].is_a?(String) and posiNr = params[:posiNr].strip and posiNr.present?
        raise( ArgumentError, "格式错误：库位容量！" )  unless params[:capacity].is_a?(String) and capacity = params[:capacity].strip
        raise( ArgumentError, "参数错误：仓库ID无效！" )  unless FormatHelper.str_is_positive_integer( whId )
        raise( ArgumentError, "参数错误：容量无效！" )  unless FormatHelper.str_is_positive_integer( capacity )
        raise( RuntimeError, "仓库不存在！" )  unless wh = @cz_org.warehouses.find_by_id(whId)
        raise( RuntimeError, "库位已存在，不可重建！" )  if wh.positions.where( :nr=>posiNr ).first
        posi = Position.new( :nr=>posiNr, :capacity=>capacity )
        @whid = whId
        @positions = wh.positions.order("nr desc")
        @newposi ||= []
        @newposi << posi
        render :json => {:flag=>true, :msg=>"新建库位成功。", :txt=>render_to_string(:partial=>"positions_list") }
      rescue Exception => e
        render :json => {:flag=>false, :msg=>e.to_s}
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
        @positions = posi.warehouse.positions.order("nr desc")
        @newposi = []
        render :json => {:flag=>true, :msg=>"删除库位成功。", :txt=>render_to_string(:partial=>"positions_list") }
      else
        render :json => {:flag=>false, :msg=>"失败！"}
      end
    # rescue Exception => e
      # render :json => {:flag=>false, :msg=>e.to_s}
    end
  end
  
  def search_state
    if request.get?
      @whlist = Warehouse.selection_list(@cz_org)
    else
      begin
        conditions = {}
        if params[:whId].present?
          whId = params[:whId].is_a?(String) ? params[:whId].strip : params[:whId]
          raise( ArgumentError, "参数错误：仓库ID无效！" )  unless FormatHelper.str_is_positive_integer( whId )
        else
          raise( ArgumentError, "条件缺失：请选择仓库！" )
        end
        if params[:posiNr].present?
          raise( ArgumentError, "格式错误：库位！" )  unless params[:posiNr].is_a?(String)
          posiNr = params[:posiNr].strip
          conditions['positions.nr']=posiNr
        end
        if params[:partNr].present?
          raise( ArgumentError, "格式错误：零件号！" )  unless params[:partNr].is_a?(String)
          partNr = params[:partNr].strip
          conditions['parts.partNr']=partNr
        end
        if params[:stockStart].present?
          stockStart = params[:stockStart].is_a?(String) ?  params[:stockStart].strip :  params[:stockStart]
          raise( ArgumentError, "参数错误：起始数量无效！" )  unless FormatHelper.str_is_positive_float( stockStart )
        end
        if params[:stockEnd].present?
          stockEnd = params[:stockEnd].is_a?(String) ?  params[:stockEnd].strip :  params[:stockEnd]
          raise( ArgumentError, "参数错误：终止数量无效！" )  unless FormatHelper.str_is_positive_float( stockEnd )
        end
        if stockStart.present? and stockEnd.present?
          aggregations = "sum(storages.stock) > " + stockStart + "and sum(storages.stock) < " + stockEnd
        elsif stockStart.blank? and stockEnd.present?
          aggregations = "sum(storages.stock) > " + 0.to_s + " and sum(storages.stock) < " + stockEnd
        elsif stockStart.present? and stockEnd.blank?
          aggregations = "sum(storages.stock) > " + stockStart
        else
          aggregations = ""
        end
        raise( RuntimeError, "仓库不存在！" )  unless wh = @cz_org.warehouses.find_by_id(whId)
        
        @positions = wh.positions.joins(:warehouse, :storages=>:part)
                                  .where( conditions )
                                  .select('warehouses.nr as whNr, positions.nr, parts.partNr, sum(storages.stock) as stock')
                                  .group('positions.id')
                                  .having(aggregations)
                                  .limit($DEPSIZE).offset($DEPSIZE*params[:page].to_i)
        @total = @positions.length
        @totalPages = @total / $DEPSIZE + (@total%$DEPSIZE==0 ? 0:1)
        @currentPage=params[:page].to_i
        render :partial=>"state_list"
      rescue Exception => e
        render :text => e.to_s
      end
    end
  end
  
  def search_op_history
    if request.get?
      @whlist = Warehouse.selection_list(@cz_org)
      @opType = StorageOpType.all.map { |t| [t.desc, t.value] }
    else
      begin
        conditions = {}
        if params[:whId].present?
          whId = params[:whId].is_a?(String) ? params[:whId].strip : params[:whId]
          raise( ArgumentError, "参数错误：仓库ID无效！" )  unless FormatHelper.str_is_positive_integer( whId )
        else
          raise( ArgumentError, "条件缺失：请选择仓库！" )
        end
        if params[:posiNr].present?
          raise( ArgumentError, "格式错误：库位！" )  unless params[:posiNr].is_a?(String)
          posiNr = params[:posiNr].strip
          conditions['positions.nr']=posiNr
        end
        if params[:partNr].present?
          raise( ArgumentError, "格式错误：零件号！" )  unless params[:partNr].is_a?(String)
          partNr = params[:partNr].strip
          conditions['parts.partNr']=partNr
        end
        if params[:opType].present?
          raise( ArgumentError, "格式错误：操作类型！" )  unless params[:opType].is_a?(String)
          opType = params[:opType].strip
          conditions[:opType]=opType
        end
        if params[:amountStart].present?
          amountStart = params[:amountStart].is_a?(String) ?  params[:amountStart].strip :  params[:amountStart]
          raise( ArgumentError, "参数错误：起始数量无效！" )  unless FormatHelper.str_is_positive_float( amountStart )
        end
        if params[:amountEnd].present?
          amountEnd = params[:amountEnd].is_a?(String) ?  params[:amountEnd].strip :  params[:amountEnd]
          raise( ArgumentError, "参数错误：终止数量无效！" )  unless FormatHelper.str_is_positive_float( amountEnd )
        end
        astart = amountStart ? amountStart.to_f : 0.0
        aend = amountEnd ? amountEnd.to_f : 99999999.0
        conditions[:amount] = astart..aend
        raise( RuntimeError, "仓库不存在！" )  unless wh = @cz_org.warehouses.find_by_id(whId)
        
        @operations = wh.storage_histories.joins(:part, :position=>:warehouse)
                                  .where( conditions )
                                  .select('warehouses.nr as whNr, positions.nr, parts.partNr, storage_histories.*')
                                  .limit($DEPSIZE).offset($DEPSIZE*params[:page].to_i)
        @total = @operations.length
        @totalPages = @total / $DEPSIZE + (@total%$DEPSIZE==0 ? 0:1)
        @currentPage=params[:page].to_i
        render :partial=>"op_history_list"
      rescue Exception => e
        render :text => e.to_s
      end
    end
  end
  
end
