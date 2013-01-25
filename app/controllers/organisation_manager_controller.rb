#coding:utf-8
class OrganisationManagerController < ApplicationController

  before_filter  :authorize
  def index
    # @list = Organisation.option_list
    @org = @cz_org
    # @org = Organisation.find(3)
  end
  
  def edit
    if request.get?
    elsif request.post?
      @org = Organisation.find(params[:id])
      render :partial => "edit"
    end
  end
  
  def update
    if org = Organisation.find(params[:id])  and
      org.update_attributes(:name=>params[:name], :description=>params[:description], 
      :address=>params[:address], :tel=>params[:tel], :website=>params[:website], 
      :abbr=>params[:abbr], :contact=>params[:contact], :email=>params[:email])
      render :json=>{flag:true,msg:"修改成功"}
    else
      render :json=>{flag:false,msg:"修改失败"}
    end
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


  #################  for Fuzzy Search
  def redis_search
    if params[:term].blank?
      render :text => ""
    return
    end
    params[:term].gsub!(/'/,'')
    if session[:orgOpeType]==OrgOperateType::Client
      @search = Redis::Search.complete("OrganisationRelation", params[:term], :conditions=>{:origin_client_id=>@cz_org.id} )
    else
      @search = Redis::Search.complete("OrganisationRelation", params[:term], :conditions=>{:origin_supplier_id=>@cz_org.id} )
    end
    if params[:getId]
      lines = @search.collect{|item| {:csNr=>item['title'],:org=>item['id']}}
    elsif session[:orgOpeType]==OrgOperateType::Client
      lines = @search.collect{|item|item['clientNr'] }
    else
      lines = @search.collect{|item|item['supplierNr'] }
    end
    respond_to do |format|
      format.xml {render  xml:lines}
      format.json { render json: lines }
      format.json { render text: lines }
    end
  # render :text => lines
  end

end
