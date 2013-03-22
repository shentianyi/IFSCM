#encoding: utf-8
class PartController<ApplicationController

  before_filter  :authorize
  def searcher

  end

  # ws part redis search
  def redis_search
    parts=[]
    search = Redis::Search.complete("Part",params[:term],:conditions=>{:organisation_id=>@cz_org.id})
    #   puts @search
    search.each do |item|
      parts<<item['partNr']
      puts "-"*30
      puts item['partNr']
      puts "-"*30
    end
    respond_to do |format|
      format.xml {render :xml=>JSON.parse(parts.to_json).to_xml(:root=>'parts')}
      format.json { render json: parts }
      format.text { render :text=> parts }
    end
  end

  # ws
  # [功能：] 分页获取组织关系零件关系元数组及总数
  # 参数：
  # - string - partnerNr
  # - string - partNr
  # - string : pageIndex
  # 返回值：
  # - Array : 零件关系元数组
  def get_partRels
    if request.post?
      @currentPage=pageIndex=params[:pageIndex].to_i
      partRels,@totalCount=PartRelBll.get_part_rel_by_partnerNr(session[:org_id],params[:partnerNr],session[:orgOpeType],params[:partNr],$DEPSIZE,pageIndex)
      @totalPages=PageHelper::generate_page_count @totalCount,$DEPSIZE
      respond_to do |format|
        format.xml {render :xml=>JSON.parse(partRels.to_json).to_xml(:root=>'partRels')}
        format.json { render json: partRels }
        format.html { render partial:'send_delivery_parts',:locals=>{:partRels=>partRels}}
      end
    end
  end

  def strategy
    if request.get?
      @currentPage=pageIndex=params[:p].to_i
      @s=params[:s]
      @sparts,@totalCount=PartRelBll.get_part_rel_by_partnerId(session[:org_id],params[:s],session[:orgOpeType],18,pageIndex,false)
      @org=Organisation.find(params[:s])
      @points=@cz_org.warehouses.where(:type=>WarehouseType::Tippoint).collect{|w| [w.nr,w.id]}
      @strategies=DeliveryObjInspect.all.collect{|item| [item.value,item.desc]}
      @totalPages=PageHelper::generate_page_count @totalCount,18
    else     
       vmsg=PartBll.strategy_vali(params[:strategy].to_i,params[:ware].to_i,params[:posiNr],(params[:demote].to_i==1),params[:demoteTimes],params[:least])
       msg=ReturnMsg.new(:result=>vmsg.result,:content=>vmsg.content)
      if msg.result
        Resque.enqueue(PartStrategyUpdater,params[:ids].split(','),vmsg.object,params[:strategy],(params[:demote].to_i==1),params[:demoteTimes],params[:least])
      end
    end
    respond_to do |format|
        format.json { render json: msg }
        format.html  
      end
  end
  
  def strategyinfo
    msg=ReturnMsg.new
    if info=PartRelInfo.find(params[:id])
      msg.result=true
      msg.object=info
    end
    render :json=>msg
  end


end