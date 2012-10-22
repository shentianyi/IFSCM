class OrganisationManagerController < ApplicationController
  def index

    # @ids.each do |id|
        # forecast = $redis.hgetall(id)
        # forecast["id"] = id
        # @forecasts << forecast
    # end
    @orgs = []
    puts "_____________________________________________________________________________________________________\n"
    p params[:notice]
    if org = params[:notice]
      @orgs << org
      puts "_____________________________________________________________________________________________________\n"
    else
      $redis.keys( Rns::Org+"*" ).each do |key|
        hash = $redis.hgetall( key )
        hash["key"] = key
        @orgs << hash
      end
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @orgs }
    end
  end
  
  def create
    
    key = Organisation.get_key(107)
    puts "----------------------------"<<params.to_a.to_s
    puts "\n\n\n"
    if Organisation.new( key, :client=>params[:client],
                                                      :supplier=>params[:supplier],
                                                      :partNo=>params[:partNo],
                                                      :date=>params[:date],
                                                      :type=>params[:type] )
      org = Organisation.find( key )
      org["key"] = key
    end
    
    redirect_to organisation_manager_index_path, :notice=>org
  end
  
end
