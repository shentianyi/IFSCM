class OrganisationManagerController < ApplicationController
  
  def index

    @orgs = []
    $redis.keys( Rns::Org+":*" ).each do |k|
        org = Organisation.find( k )
        @orgs << org
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @orgs }
    end
  end
  
  def create
    key = Organisation.get_key( params[:id] )
    if $redis.exists( key )
    else
      organisation = Organisation.new( :key=>key, 
                                                        :name=>params[:name],
                                                        :address=>params[:address],
                                                        :tel=>params[:tel],
                                                        :website=>params[:website] )
      organisation.save
    end
    
    redirect_to organisation_manager_index_path
  end
  
  def show
    @list = Organisation.option_list
    if @org = Organisation.find( params[:id] )
      @orgs = @org.list( @org.s_key )
    else
      @org = Organisation.new
      @orgs = []
    end
  end
  
  def add_supplier
    org = Organisation.find( params[:key] )
    org.add_supplier( params[:orgId], params[:name] )
    Supplier.new( s_key:org.s_key, supplierNr:params[:name] ).save_index
    
    redirect_to organisation_manager_path( org.key )
  end
  
  #################  for Fuzzy Search
  def search
    if params[:q].blank?
      render :text => ""
      return
    end
    params[:q].gsub!(/'/,'')
    @search = Redis::Search.query("Supplier", params[:q], :conditions=>{:s_key=>"12345:#{Rns::S}"} )
    # @search = Redis::Search.complete("Forecast", params[:q])
    puts @search
    lines = @search.collect do |item|
      "#{item['title']}#!##{item['id']}#!##{item['name']}#!##{item['name']}#!##{item['name']}"
    end
    render :text => lines.join("\n")
  end
  
end
