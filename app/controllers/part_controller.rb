class PartController<ApplicationController
  
  before_filter  :authorize
    include PageHelper
    
  def searcher

  end

  # ws part redis search
  def redis_search
    org_id=@cz_org.id
    params[:term].gsub!(/'/,'')
    parts=[]
    @search = Redis::Search.complete("Part", params[:term],:conditions=>{:orgId=>org_id})
    puts @search
    @search.collect do |item|
      parts<<item['partNr']
      # parts<<(Part.new(:key=>item['key'],:orgId=>item['orgId'],:partNr=>item['partNr'],:created_at=>Time.at(item['created_at'])))
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
        if orgOpeType==OrgOperateType::Client
          parts=Part.get_all_relation_parts(org_id,partnerId,PartRelType::Client)
        elsif
        parts=Part.get_all_relation_parts(partnerId,org_id,PartRelType::Supplier)
        end
      end
    end
    respond_to do |format|
      format.xml {render :xml=>JSON.parse(demands.to_json).to_xml(:root=>'parts')}
      format.json { render json: parts }
      format.html { render partial:'_relationd_parts',:locals=>{:parts=>parts}}
    end
  end
  
  # ws get parts by condtions
  def get_parts_by_condtions
    
  end
  # ws gell all part rels
  # def get_all_partRels_by_cusId
    # if request.post?
      # cusId=params[:customerId]
      # @currentPage=pageIndex=params[:pageIndex].to_i
        # startIndex,endIndex=PageHelper::generate_page_index(pageIndex,$DEPSIZE)
        # demands,@totalCount= DemanderHelper::get_file_demands fileId,startIndex,endIndex,type
#         
    # end
  # end
  
  
end