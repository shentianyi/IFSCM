#coding:utf-8
require 'enum/file_data_type'

class DemanderController<ApplicationController
  
  #include
  include DemanderHelper
  
  # ws upload demands from csv
  def upload_demands
    if request.get?
      else
      files=params[:files]
      begin
        path='uploadfiles/demands/csv'
        hfiles=[]
        if files.count>0
          uuid=UUID.new
          files.each do |f|
            hf={:oriName=>f.original_filename,:uuidName=>uuid.generate,:path=>path}
            dcsv=FileData.new :data=>f,:type=>FileDataType::Demand,:oriName=>f.original_filename,:uuidName=>uuid.generate,:path=>path
            dcsv.save
            hf[:pathName]=dcsv.pathName
            hfiles<<hf
          end
        
          # clietId should be from session
          clientId=session[:userId]
          # validate and show result
           generate_by_csv(hfiles,clientId)
          
          #...........
            render :json=>{:flag=>true,:msg=>'ok'}
        else
          render :json=>{:flag=>false,:msg=>'no files'}
        end
      rescue=>e
         render :json=>{:flag=>false,:msg=>'rescue'}
      end
    end
  end
  
  def index
    @demands = []
    if request.get?
        $redis.keys( "#{Rns::De}:*" ).each do |key|
          hash = $redis.hgetall( key )
          hash["key"] = key
          @demands << hash
        end
    else
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @demands }
    end
  end
  
  def create
    key = Demander.get_key( params[:id] )
    if $redis.exists( key )
    else
      demand = Demander.new( key, :client=>params[:client],
                                                                                  :supplier=>params[:supplier],
                                                                                  :partNr=>params[:partNr],
                                                                                  :date=>params[:date],
                                                                                  :type=>params[:type] )
      demand.save
    end
    
    redirect_to root_path
  end
  
  def search
    
    @demands = []
    key = Demander.search( :client=>params[:client],
                                                                    :supplier=>params[:supplier],
                                                                    :partNr=>params[:partNr],
                                                                    # :date=>{ :start=>params[:start], :end=>params[:end] },
                                                                    :type=>params[:type] )
    start = params[:start].size>0 ? params[:start].to_i : -(1/0.0)
    timeend = params[:end].size>0 ? params[:end].to_i : (1/0.0)
    # puts "#{$redis.zcount( key, start, timeend)}"+"_"*200
    $redis.zrangebyscore( key, start, timeend, :withscores=>true ).each do |item|
          hash = $redis.hgetall( item[0] )
          hash["key"] = item
          @demands << hash
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @demands }
    end
  end
end