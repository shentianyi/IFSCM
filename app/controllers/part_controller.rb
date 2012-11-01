class PartController<ApplicationController
  def searcher

  end

  # ws part redis search
  def redis_search
    session[:userId]=1
    userId=session[:userId]
    params[:q].gsub!(/'/,'')
    parts=[]
    @search = Redis::Search.complete("Part", params[:q],:conditions=>{:orgId=>userId})
    @search.collect do |item|
    # puts item
      parts<<(Part.new(:key=>item['key'],:orgId=>item['orgId'],:partNr=>item['partNr'],:created_at=>Time.at(item['created_at'])))
    end
    respond_to do |format|
      format.xml {render :xml=>JSON.parse(parts.to_json).to_xml(:root=>'parts')}
      format.json { render json: parts }
    end
  end

  #ws Get Partnrs By PartnerNr
  def get_partNrs_by_partnerNr
    userId=session[:userId]
    orgOpeType=session[:orgOpeType]
    partnerNr=params[:partnerNr]
    parts=[]

    if org=Organisation.find_by_id(userId)
      if  partnerId=org.get_parterId_by_parterNr(orgOpeType,partnerNr)
        if orgOpeType==OrgOperateType::Client
          parts=Part.get_all_relationd_parts(userId,partnerId,PartRelType::Client)
        elsif
        parts=Part.get_all_relationd_parts(partnerId,userId,PartRelType::Supplier)
        end
      end
    end
    respond_to do |format|
      format.xml {render :xml=>JSON.parse(demands.to_json).to_xml(:root=>'parts')}
      format.json { render json: parts }
      format.html { render partial:'_relationd_parts',:locals=>{:parts=>parts}}
    end
  end
end