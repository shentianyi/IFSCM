class PartController<ApplicationController

  before_filter  :authorize
  include PageHelper
  def searcher

  end

  # ws part redis search
  def redis_search
    org_id=@cz_org.id
    parts=[]
    @search = Redis::Search.complete("Part",params[:term],:conditions=>{:orgId=>org_id})
    #   puts @search
    @search.collect do |item|
      parts<<item['partNr']
    end
    respond_to do |format|
      format.xml {render :xml=>JSON.parse(parts.to_json).to_xml(:root=>'parts')}
      format.json { render json: parts }
      format.text { render :text=> parts }
    end
  end

  #ws Get parts By PartnerNr
  def get_parts_by_partnerNr
    org_id=session[:org_id]
    orgOpeType=session[:orgOpeType]
    partnerNr=params[:partnerNr]
    parts=[]

    if org=Organisation.find_by_id(org_id)
      if  partnerId=org.get_parterId_by_parterNr(orgOpeType,partnerNr)
        # if orgOpeType==OrgOperateType::Client
          # #parts=Part.get_all_relation_parts(org_id,partnerId,PartRelType::Client)
        # elsif
        # #parts=Part.get_all_relation_parts(partnerId,org_id,PartRelType::Supplier)
        # end
      end
    end
    respond_to do |format|
      format.xml {render :xml=>JSON.parse(demands.to_json).to_xml(:root=>'parts')}
      format.json { render json: parts }
      format.html { render partial:'relationd_parts',:locals=>{:parts=>parts}}
    end
  end

  # ws get parts by condtions in page
  def get_part_rel_meta_inpage
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