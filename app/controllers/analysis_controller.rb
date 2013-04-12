#encoding: utf-8
class AnalysisController < ApplicationController
  
  before_filter  :authorize
  
  def demand_cf
    if request.get?
    elsif request.post?
        begin
            c = params[:client]
            s = params[:supplier]
            raise( ArgumentError, "缺少条件：零件号！" )  unless params[:partNr].is_a?(String) and p = params[:partNr].strip and p.present?
            raise( ArgumentError, "缺少条件：起始时间！" )  unless params[:start].present?
            raise( ArgumentError, "缺少条件：结束时间！" )  unless params[:end].present?
            tStart = Time.parse(params[:start]).to_i
            tEnd = Time.parse(params[:end]).to_i
            raise( ArgumentError, "开始时间应小于结束时间！" )  if tStart>tEnd
            type = params[:type].strip if params[:type].is_a?(String)
        
            ######  判断类型 C or S ， 将session[:id]赋值给 id
        
            if session[:orgOpeType]==OrgOperateType::Client
              raise( ArgumentError, "缺少条件：供应商号！" )  if s.blank?
              raise( ArgumentError, "供应商不存在！" )  unless org_rel = @cz_org.suppliers.where( supplierNr:s ).first
              supplierId = org_rel.origin_supplier_id
              clientId = @cz_org.id
              partrelId = @cz_org.parts.joins(:client_part_rels).where(:partNr=>p, :part_rels=>{:organisation_relation_id=>org_rel.id}).select("part_rels.id").first
            else
              raise( ArgumentError, "缺少条件：客户号！" )  if c.blank?
              raise( ArgumentError, "客户不存在！" )  unless org_rel = @cz_org.clients.where( clientNr:c ).first
              clientId = org_rel.origin_client_id
              supplierId = @cz_org.id
              partrelId = @cz_org.parts.joins(:supplier_part_rels).where(:partNr=>p, :supplier_part_rels=>{:organisation_relation_id=>org_rel.id}).select("part_rels.id").first
            end
            raise( ArgumentError, "零件不存在！" )  if partrelId.blank?
            partrelId = partrelId.id
            
            chart = []
            raise( RuntimeError, "CF值不存在！" )  unless cf = Demander.get_cf_by_range( partrelId, tStart, tEnd, type )
            chart += [[1,cf],[2,cf]]
            raise( RuntimeError, "OTD值不存在！" )  unless otd = OnTimeDelivery.get_otd_by_range( partrelId, tStart, tEnd )
            chart += [nil,[3,otd],[4,otd]]
            
            x = [ [1.5,"需求"], [3.5,"到货"] ]
            #x = [ [1.5,"需求"], [3.5,"到货"], [5.5,"在途"]]
            tips = "#{params[:start]} - #{params[:end]}"
            
            render :json=>{:flag=>true, :chart=>chart, :x=>x, :partNr=>p, :type=>type, :tips=>tips }
        rescue Exception => e
          render :json=>{:flag=>false, :msg=>e.to_s}
        end
    end
  end
  
  def order_progress
    if request.get?
    elsif request.post?
      begin
        raise( ArgumentError, "请输入订单号！" )  unless params[:orderNr].present? and orderNr = params[:orderNr].strip
        if session[:orgOpeType]==OrgOperateType::Client
          orders = @cz_org.order_items.where(:orderNr=>orderNr)
        else
          orders = @cz_org.client_order_items.where(:orderNr=>orderNr)
        end
        
        @orderitems = orders.map { |o| [o, Demander.find_by_key(o.demander_key)] }
        if @orderitems.blank?
          render :text=>"没有找到相关数据！"
        else
          render :partial => "order_item_list"
        end
      # rescue Exception => e
        # render :text=>e.to_s
      end
    end
  end
  
  
end
