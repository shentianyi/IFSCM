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
            dcsv=FileData.new({:data=>f,:type=>FileDataType::Demand}.merge(hf))
            dcsv.save
            hf[:pathName]=dcsv.pathName
            hfiles<<hf
          end
        
          # validate and show result
           generate_by_csv(hfiles)
          
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
      puts "-"*10+"this is index"
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @demands }
    end
  end
  
  def create
    key = Demander.get_key( params[:id] )
    # key = "#{Rns::De}:#{params[:id]}"
    if $redis.exists( key )
      # puts "_"*200
    else
      demand = Demander.new( key, :client=>params[:client],
                                                                                  :supplier=>params[:supplier],
                                                                                  :partNr=>params[:partNr],
                                                                                  :date=>params[:date],
                                                                                  :type=>params[:type] )
      # puts "成功" 
    end
    
    redirect_to root_path
  end
  
  def search
    
    @demands = []
    key = Demander.new().search( :client=>params[:client],
                                                                    :supplier=>params[:supplier],
                                                                    :partNr=>params[:partNr],
                                                                    # :date=>{ :start=>params[:start], :end=>params[:end] },
                                                                    :type=>params[:type] )
    start = params[:start]?params[:start]:0
    timeend = params[:end]?params[:end]:-1
    $redis.zrange( key, start, timeend, :withscores=>false ).each do |item|
          hash = $redis.hgetall( item )
          hash["key"] = item
          @demands << hash
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @demands }
    end
  end
end