#coding:utf-8
require 'enum/file_data_type.rb'

class DemanderController<ApplicationController

  #include
  include DemanderHelper
  # ws upload demands from csv -- support muti files
  def upload_files
    session[:userId]=1
    if request.get?
      else
      files=params[:files]
      puts '---------------------------'
      puts files
      begin
        msg=ReturnMsg.new(:result=>false,:content=>'')
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
          #render :json=>{:flag=>true,:filesInfo=>batch_file}
          msg.result=true
          msg.object=batch_file
          else
            msg.content='upload faild please retry'
          end
        else
          msg.content='no files'
        end
      rescue Exception => e
        msg.content=e.message+'//'+ e.backtrace.inspect
      end
      respond_to do |format|
        format.xml {render :xml=>JSON.parse(msg.to_json).to_xml(:root=>'FilesInfo')}
        format.json { render json: msg }
      end
    end
  end

  # ws get file item errors
  def get_error
    if request.post?
      demands=get_demand_items 'error'
      respond_to do |format|
        format.xml {render :xml=>JSON.parse(demands.to_json).to_xml(:root=>'Demands')}
        format.json { render json: demands }
        format.html { render partial:'error_items',:locals=>{:demands=>demands}}
      end
    end
  end

  # ws get file item normals
  def get_normal
    if request.post?
      demands=get_demand_items 'normal'
      respond_to do |format|
        format.xml {render :xml=>JSON.parse(demands.to_json).to_xml(:root=>'Demands')}
        format.json { render json: demands }
        format.html { render partial:'normal_items',:locals=>{:demands=>demands}}
      end
    end
  end

  def index
    @demands = []
    if request.get?
        $redis.keys( "#{Rns::De}:*" ).each do |k|
          demander = Demander.find( k )
          # hash["score"] = $redis.zscore( Rns::Date, k )
          @demands << demander
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
      demand = Demander.new( :key=>key, :clientId=>params[:client],
                                                                                  :supplierId=>params[:supplier],
                                                                                  :relpartId=>params[:partNr],
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

  private

  # ws private get demands
  def get_demand_items type
    fileId=params[:fileId]
    pageIndex=params[:pageIndex].to_i
    pageSize=$DEPSIZE
    startIndex=(pageIndex-1)*pageSize
    endIndex=pageIndex*pageSize-1
    return DemanderHelper::get_file_demands fileId,startIndex,endIndex,type
  end

end