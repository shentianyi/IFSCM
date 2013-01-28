#encoding: utf-8

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
          cs = cs.present? ?  cs : "none" 
          @search = Redis::Search.complete("OrganisationRelation", cs, :conditions=>{:origin_client_id=>@cz_org.id} )  ||[]
          @organs = @search.collect{|item| [ item["supplierNr"], Organisation.find_by_id(item['origin_supplier_id'].to_i) ]  }
      else
          cs = cs.present? ?  cs : "none" 
          @search = Redis::Search.complete("OrganisationRelation", cs, :conditions=>{:origin_supplier_id=>@cz_org.id} ) ||[]
          @organs = @search.collect{|item| [ item["clientNr"], Organisation.find_by_id(item['origin_client_id'].to_i) ]  }
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
      lines = @search.collect{|item|item['supplierNr'] }
    else
      lines = @search.collect{|item|item['clientNr'] }
    end
    respond_to do |format|
      format.xml {render  xml:lines}
      format.json { render json: lines }
      format.json { render text: lines }
    end
  # render :text => lines
  end

end
