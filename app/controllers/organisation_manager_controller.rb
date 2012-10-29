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
    
    redirect_to organisation_manager_path( org.key )
  end
  
end
