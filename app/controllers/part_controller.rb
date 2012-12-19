class PartController<ApplicationController

  before_filter  :authorize
  include PageHelper
  def searcher

  end

  # ws part redis search
  def redis_search
    org_id=@cz_org.id
    parts=[]
    search = Redis::Search.complete("Part",params[:term],:conditions=>{:orgId=>org_id})
    #   puts @search
    search.collect do |item|
      parts<<item['partNr']
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
      startIndex,endIndex=PageHelper::generate_page_index(pageIndex,$DEPSIZE)
      partRels,@totalCount=PartRelMetaHelper::get_part_rel_metas_by_parterNr(session[:org_id],params[:partnerNr],session[:orgOpeType],params[:partNr],startIndex,endIndex)
      @totalPages=PageHelper::generate_page_count @totalCount,$DEPSIZE
      respond_to do |format|
        format.xml {render :xml=>JSON.parse(partRels.to_json).to_xml(:root=>'partRels')}
        format.json { render json: partRels }
        format.html { render partial:'send_delivery_parts',:locals=>{:partRels=>partRels}}
      end
    end
  end

  # ws get parts by condtions in page
  # redis-search
  def redis_search_meta
    @currentPage=pageIndex=params[:pageIndex].to_i
    startIndex=pageIndex*$DEPSIZE
    prms,@totalCount=PartRelMetaHelper::redis_search_by_conditions(params[:q],:conditions=>{:orgIds=>session[:org_id]},:startIndex=>startIndex,:take=>$DEPSIZE)
    @totalPages=PageHelper::generate_page_count @totalCount,$DEPSIZE
    respond_to do |format|
      format.xml {render :xml=>JSON.parse(demands.to_json).to_xml(:root=>'prms')}
      format.json { render json: prms }
      format.html { render partial:'part_rel_metas',:locals=>{:prms=>prms}}
    end
  end

end