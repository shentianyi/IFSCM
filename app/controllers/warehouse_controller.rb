#encoding: utf-8
class WarehouseController < ApplicationController
  
  before_filter  :authorize
  
  def stock_out_list
    begin
      raise( ArgumentError, "格式错误：仓库ID！" )  unless params[:whId].is_a?(String) and warehouseId = params[:whId].strip
      raise( ArgumentError, "格式错误：零件号！" )  unless params[:partNr].is_a?(String)  and partNr = params[:partNr].strip
      raise( ArgumentError, "参数错误：仓库ID无效！" )  unless FormatHelper.str_is_positive_integer( warehouseId )
      raise( RuntimeError, "仓库不存在！" )  unless wh = @cz_org.warehouses.find_by_id(warehouseId)
      raise( RuntimeError, "零件不存在！" )  unless part = @cz_org.parts.find_by_partNr(partNr)
      posis = wh.positions.by_partId(part.id)
      if posis.present?
        @whid = warehouseId
        @posilist = posis
        @costcenterlist = CostCenter.selection_list(@cz_org)
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
        raise( ArgumentError, "格式错误：库位ID！" )  unless params[:posiId].is_a?(String) and posiId = params[:posiId].strip
        raise( ArgumentError, "格式错误：零件号！" )  unless params[:partNr].is_a?(String) and partNr = params[:partNr].strip
        raise( ArgumentError, "格式错误：出库量！" )  unless params[:amount].is_a?(String) and amount = params[:amount].strip
        raise( ArgumentError, "格式错误：成本中心！" )  unless params[:ccName].is_a?(String) and ccName = params[:ccName].strip
        ccName = "无"  if ccName.blank?
        raise( ArgumentError, "参数错误：库位ID无效！" )  unless FormatHelper.str_is_positive_integer( posiId )
        raise( ArgumentError, "参数错误：出库量无效！" )  unless FormatHelper.str_is_positive_float( amount )
        raise( ArgumentError, "出库量应大于0！" )  unless amount.to_f > 0
        raise( RuntimeError, "零件不存在！" )  unless part = @cz_org.parts.find_by_partNr(partNr)
        if params[:scrap].present? and params[:scrap]=="true"
          msg = WarehouseBll.position_out( posiId.to_i, part.id, amount.to_f, ccName, true )
        else
          msg = WarehouseBll.position_out( posiId.to_i, part.id, amount.to_f, ccName )
        end
        if msg.result
          render :json => {:flag=>true, :msg=>msg.content, :obj=>msg.object}
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
        type = params[:checkware].present? ? (WarehouseType::Tippoint) : (WarehouseType::Normal)
        wh = Warehouse.new( :nr=>whNr, :name=>whName, :type=>type )
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
        raise( ArgumentError, "格式错误：仓库ID！" )  unless params[:whId].is_a?(String) and whId = params[:whId].strip
        raise( ArgumentError, "格式错误：页码！" )  unless params[:page].is_a?(String) and page = params[:page].strip
        raise( ArgumentError, "仓库无效！" )  unless FormatHelper.str_is_positive_integer( whId )
   #     raise( ArgumentError, "参数错误：页码无效！" )  unless FormatHelper.str_is_positive_integer( page )
        if wh = Warehouse.find_by_id(whId)
          positions = wh.positions.order("nr asc")
          @total = positions.count
          @positions = positions.limit($DEPSIZE).offset($DEPSIZE*page.to_i)
          @totalPages = @total / $DEPSIZE + (@total%$DEPSIZE==0 ? 0:1)
          @currentPage=page.to_i
          render :partial => "positions_list"
        else
          render :text => "没有找到相关仓库！"
        end
      rescue Exception => e
        render :text => e.to_s
      end
    else
      begin
        render :json => {:flag=>true, :msg=>"新建库位成功。"}
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
        raise( RuntimeError, "库位范围过大，请缩小范围！" )  if (posiStart..posiEnd).count > 150
        (posiStart..posiEnd).each do |p|
          posi = Position.new( :nr=>p, :capacity=>capa )
          posi.errors[:temp]="重复"  if wh.positions.where( :nr=>p ).first
          if posi.errors.blank? and wh.positions << posi
          else
            posi.errors[:temp]="错误"  if posi.errors.blank?
          end
        end
          render :json => {:flag=>true, :msg=>"新建库位成功。" }
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
        raise( RuntimeError, "失败" )  unless wh.positions << posi
        render :json => {:flag=>true, :msg=>"新建库位成功。"}
      rescue Exception => e
        render :json => {:flag=>false, :msg=>e.to_s}
      end
  end
  
  def delete_position
    begin
      raise( ArgumentError, "格式错误：仓库ID！" )  unless params[:whId].is_a?(String) and whId = params[:whId].strip and whId.present?
      raise( ArgumentError, "格式错误：库位！" )  unless params[:posiNr].is_a?(String) and posiNr = params[:posiNr].strip and posiNr.present?
      raise( RuntimeError, "仓库不存在！" )  unless wh = @cz_org.warehouses.find_by_id(whId)
      raise( RuntimeError, "库位不存在！" )  unless posi = wh.positions.where( :nr=>posiNr ).first
      raise( RuntimeError, "不可删除，必须先清空其所有库存量！" )  if posi.stock>0
      if posi.destroy
        @whid = wh.id
        render :json => {:flag=>true, :msg=>"删除库位成功。"}
      else
        render :json => {:flag=>false, :msg=>"失败！"}
      end
    rescue Exception => e
      render :json => {:flag=>false, :msg=>e.to_s}
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
        
        positions = wh.positions.joins(:warehouse, :storages=>:part)
                                  .where( conditions )
                                  .select('warehouses.nr as whNr, positions.nr, parts.partNr, sum(storages.stock) as total')
                                  .order("positions.nr asc")
                                  .group('positions.id')
                                  .having(aggregations)
        @total = positions.length
         if @total == 0
          render :text=>"没有搜索到相关数据！"
        else
          @positions = positions.limit($DEPSIZE).offset($DEPSIZE*params[:page].to_i)
          @totalPages = @total / $DEPSIZE + (@total%$DEPSIZE==0 ? 0:1)
          @currentPage=params[:page].to_i
          render :partial=>"state_list"
        end
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
        
        operations = wh.storage_histories.joins(:part, :position=>:warehouse)
                                  .where( conditions )
                                  .select('warehouses.nr as whNr, positions.nr, parts.partNr, storage_histories.*')
        @total = operations.count
        if @total == 0
          render :text=>"没有搜索到相关数据！"
        else
          @operations = operations.limit($DEPSIZE).offset($DEPSIZE*params[:page].to_i)
          @totalPages = @total / $DEPSIZE + (@total%$DEPSIZE==0 ? 0:1)
          @currentPage=params[:page].to_i
          render :partial=>"op_history_list"
        end
      rescue Exception => e
        render :text => e.to_s
      end
    end
  end
  
  # def tippoint
    # if request.get?
      # @points=@cz_org.warehouses.where(:type=>WarehouseType::Tippoint).all      
    # end
  # end
#   
  # def del_tippoint
#     
  # end
#   
  # def update_tippoint
  # end
end
