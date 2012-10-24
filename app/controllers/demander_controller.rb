#coding:utf-8
require 'enum/file_data_type.rb'

class DemanderController<ApplicationController

  #include
  include DemanderHelper
  # ws upload demands from csv -- support muti files
  def upload_demands
    session[:userId]=1
    if request.get?
      else
      files=params[:files]
      puts '---------------------------'
      puts files
      begin
        path=$DECSVP
        hfiles=[]
        if files.count>0
          uuid=UUID.new
          files.each do |f|
            uuidName=uuid.generate
            hf={:oriName=>f.original_filename,:uuidName=>uuidName,:path=>path}
            # puts FileDataType::Demand
            dcsv=FileData.new(:data=>f,:type=>FileDataType::Demand,:oriName=>f.original_filename,:uuidName=>uuidName,:path=>path)
            dcsv.save
            hf[:pathName]=dcsv.pathName
            hfiles<<hf
          end
          # clietId should be from session
          clientId=session[:userId]
          # validate and show result
          batch_file=DemanderHelper::generate_by_csv(hfiles,clientId)
          if batch_file
            # this part will be done later....in session is the best?
            # if very batch has its state and saved in redis with datetime,
            # it will be easier to manage the upload process?
            # session[:not_finish_upload]=batch_uuid
            render :json=>{:flag=>true,:filesInfo=>batch_file}
          else
            render :json=>{:flag=>false,:msg=>'upload faild please retry'}
          end
        else
          render :json=>{:flag=>false,:msg=>'no files'}
        end
      rescue Exception => e
        render :json=>{:flag=>false,:msg=>e.message+'//'+ e.backtrace.inspect }
      end
    end
  end

  def index
    @demands = []
    if request.get?
      $redis.keys( "#{Rns::De}:*" ).each do |key|
        hash = $redis.hgetall( key )
        hash["key"] = key
        hash["score"] = $redis.zscore( Rns::Date, key )
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

      demand = Demander.new( :key=>key, :client=>params[:client],
      :supplier=>params[:supplier],
      :rpartNr=>params[:partNr],
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
    :rpartNr=>params[:partNr],
    # :date=>{ :start=>params[:start], :end=>params[:end] },
    :type=>params[:type] )
    start = params[:start].size>0 ? params[:start].to_i : -(1/0.0)
    timeend = params[:end].size>0 ? params[:end].to_i : (1/0.0)
    # puts "#{$redis.zcount( key, start, timeend)}"+"_"*200
    $redis.zrangebyscore( key, start, timeend, :withscores=>true ).each do |item|
      hash = $redis.hgetall( item[0] )
      hash["key"] = item[0]
      hash["score"] = item[1]
      @demands << hash
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @demands }
    end
  end

# def

end