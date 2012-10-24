class OrganisationManagerController < ApplicationController
  
  def index

    @orgs = []
    $redis.keys( Rns::Org+":*" ).each do |key|
        hash = $redis.hgetall( key )
        hash["key"] = key
        @orgs << hash
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @orgs }
    end
  end
  
  def create
    key = Organisation.get_key( params[:id] )
    # puts "----------------------------"<<params.to_a.to_s
    if $redis.exists( key )
    else
      organisation = Organisation.new( :key=>key, 
                                                        :name=>params[:name],
                                                        :address=>params[:address],
                                                        :tel=>params[:tel],
                                                        # :website=>params[:website],
                                                        :website=>params[:website] )
      organisation.save
    end
    
    redirect_to organisation_manager_index_path
  end
  
  def show
    @id = params[:id].delete "#{Rns::Org}:"
    key = "#{@id}:#{Rns::S}"
    @orgs = []
    $redis.zrange( key, 0, -1, :withscores=>true ).each do |item|
        hash = $redis.hgetall( "#{Rns::Org}:#{item[1].to_i}" )
        hash["SNr"] = item[0]
        # hash["key"] = key
        @orgs << hash
    end
  end
  
  def add_supplier
    @id = params[:id]
    Organisation.add_supplier( @id, params[:organisation], params[:name] )
    
    redirect_to organisation_manager_path("#{Rns::Org}:#{@id}")
  end
  
end
