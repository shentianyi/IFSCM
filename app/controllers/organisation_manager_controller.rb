class OrganisationManagerController < ApplicationController

  before_filter  :authorize
  def index
    # @list = Organisation.option_list
    @list=[]
  end

  def search
    if request.post?
      cs = params[:csNr]
      @organs = []
      if session[:orgOpeType]==OrgOperateType::Client
        if cs && cs.size>0
          id = @cz_org.search_supplier_byNr( cs )
          @organs<<[cs,Organisation.find_by_id(id)] if id.to_i!=0
        else
          @organs = @cz_org.list( @cz_org.s_key )
        end
      else
        if cs && cs.size>0
          id = @cz_org.search_client_byNr( cs )
          @organs<<[cs,Organisation.find_by_id(id)] if id.to_i!=0
        else
          @organs = @cz_org.list( @cz_org.c_key )
        end
      end
      @total = @organs.size
      s = params[:page].to_i*Demander::NumPer
      e = params[:page].to_i*Demander::NumPer+Demander::NumPer-1
      @orgs = @organs[s..e]
      puts @orgs
      @totalPages=@total/Demander::NumPer+(@total%Demander::NumPer==0 ? 0:1)
      @currentPage=params[:page].to_i
      @options = params[:options]?params[:options]:{}

      render :partial=>'searchlist'
    else
    end

  end

  def add_supplier
    if params[:orgId] && params[:name] && params[:orgId].size>0  && params[:name].size>0
      @cz_org.add_supplier( params[:orgId], params[:name] )
    else
      flash[:notice]="Can't be blank !"
    end
    redirect_to organisation_manager_path
  end

  def add_client
    if params[:orgId] && params[:name] && params[:orgId].size>0  && params[:name].size>0
      @cz_org.add_client( params[:orgId], params[:name] )
    else
      flash[:notice]="Can't be blank !"
    end
    redirect_to organisation_manager_path
  end

  #################  for Fuzzy Search
  def redis_search
    if params[:term].blank?
      render :text => ""
    return
    end
    params[:term].gsub!(/'/,'')
    if session[:orgOpeType]==OrgOperateType::Client
      @search = Redis::Search.complete("OrgRel", params[:term], :conditions=>{:cs_key=>@cz_org.s_key} )
    else
      @search = Redis::Search.complete("OrgRel", params[:term], :conditions=>{:cs_key=>@cz_org.c_key} )
    end
    if params[:getId]
      lines = @search.collect{|item| {:csNr=>item['title'],:org=>item['id']}}
    else
      lines = @search.collect do |item|
        item['title']
      end
    end
    respond_to do |format|
      format.xml {render  xml:lines}
      format.json { render json: lines }
      format.json { render text: lines }
    end
  # render :text => lines
  end

end
