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
      begin
        msg=ReturnMsg.new(:result=>false,:content=>'')
        path=$DECSVP
        hfiles=[]
        if files.count>0
          uuid=UUID.new
          files.each do |f|
            uuidName=uuid.generate
            hf={:oriName=>f.original_filename,:uuidName=>uuidName,:path=>path}
            dcsv=FileData.new(:data=>f,:type=>FileDataType::Demand,:oriName=>f.original_filename,:uuidName=>uuidName,:path=>path)
            dcsv.saveFile
            hf[:pathName]=dcsv.pathName
            hfiles<<hf
          end
          # clietId should be from session
          clientId=session[:userId]
          # validate and show result
          batch_file=DemanderHelper::generate_by_csv(hfiles,clientId)
          if batch_file
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
        format.xml {render :xml=>JSON.parse(msg.to_json).to_xml(:root=>'filesInfo')}
        format.json { render json: msg }
      end
    end
  end

  # ws get file item errors
  def get_error
    if request.post?
      demands=get_demand_items 'error'
      respond_to do |format|
        format.xml {render :xml=>JSON.parse(demands.to_json).to_xml(:root=>'demands')}
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
        format.xml {render :xml=>JSON.parse(demands.to_json).to_xml(:root=>'demands')}
        format.json { render json: demands }
        format.html { render partial:'normal_items',:locals=>{:demands=>demands}}
      end
    end
  end

  # ws correct error
  def correct_error
    session[:userId]=1
    if request.post?
      clientId=session[:userId]
      msg=ReturnMsg.new(:result=>false,:content=>'')
      hbf=RedisFile.find(params[:batchId])
      hsf=RedisFile.find(params[:fileId])
      od=DemanderTemp.find(params[:uuid])

      if hbf.count!=0 and hsf.count!=0 and od
        bf=RedisFile.new(hbf)
        puts '=======bf======'
        puts bf
        puts '+++++sf++++++'
        sf=RedisFile.new(hsf)
        puts sf

        nd= DemanderTemp.new(:key=>od.key,:cpartNr=>params[:partNr],:clientId=>clientId,:supplierNr=>params[:supplierNr],
        :filedate=>params[:filedate],:date=>params[:date],:type=>params[:type],:amount=>params[:amount],:lineNo=>od.lineNo,:source=>od.source)
        okey=od.gen_md5_repeat_key
        nkey=nd.gen_md5_repeat_key
        if okey!=nkey
          puts '------------------------------------remove repeat'+od.key
        bf.remove_repeat_item(od.gen_md5_repeat_key,od.key)
        end
        vmsg=DemanderHelper::demand_field_validate(nd,bf)
        nd.vali=vmsg.result

        if vmsg.result
          nd.rate=DemandHistory.compare_rate(
        nd.clientId,nd.supplierId,
        nd.cpartId,nd.type,nd.date,nd.amount)
        else
        nd.msg=vmsg.contents.to_json
        end
        nd.save

        #move demand
        if nd.vali.to_s!=od.vali
          from=!nd.vali ? 'normal':'error'
          to=nd.vali ? 'normal':'error'
          score=nd.vali ? nd.rate : nd.lineNo
          sf.send "move_#{from}_to_#{to}".to_sym,score,nd.key
        end
      msg.result=true
      msg.object=nd
      else
        msg.content='batchFileId or singleFileId or dmeandId not exists'
      end
      respond_to do |format|
        format.xml {render :xml=>JSON.parse(msg.to_json).to_xml(:root=>'validInfo')}
        format.json { render json: msg }
      end
    end
  end

  def index
    @demands = []
    if request.get?
      $redis.keys( "#{Rns::De}:*" ).each do |k|
        demander = Demander.find( k )
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