#coding:utf-8
require 'enum/file_data_type.rb'

class DemanderController<ApplicationController

  #include
  include DemanderHelper
  # ws
  def demand_upload
    # to the view
  end

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
            dcsv=FileData.new(:data=>f,:type=>FileDataType::CSVDemand,:oriName=>f.original_filename,:uuidName=>uuidName,:path=>path)
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
        format.html {render partial:'upfile_items',:locals=>{:msg=>msg}}
      end
    end
  end

  # ws get file item errors
  def get_tempdemand_items
    if request.post?
      fileId=params[:fileId]
      demands=[]
      file=RedisFile.find(fileId)
      if file
        type=file.errorCount.to_i>0 ? 'error':'nomal'

        pageIndex=params[:pageIndex].to_i
        pageSize=$DEPSIZE
        startIndex=(pageIndex-1)*pageSize
        endIndex=pageIndex*pageSize-1
        demands= DemanderHelper::get_file_demands fileId,startIndex,endIndex,type
      end
      respond_to do |format|
        format.xml {render :xml=>JSON.parse(demands.to_json).to_xml(:root=>'demands')}
        format.json { render json: demands }
        format.html { render partial: type+'_items',:locals=>{:demands=>demands}}
      end
    end
  end

  # # ws get file item normals
  # def get_normal
  # if request.post?
  # demands=get_demand_items 'normal'
  # respond_to do |format|
  # format.xml {render :xml=>JSON.parse(demands.to_json).to_xml(:root=>'demands')}
  # format.json { render json: demands }
  # format.html { render partial:'normal_items',:locals=>{:demands=>demands}}
  # end
  # end
  # end

  # ws correct error
  def correct_error
    session[:userId]=1
    if request.post?
      clientId=session[:userId]
      msg=ReturnMsg.new(:result=>false,:content=>'')
      bf=RedisFile.find(params[:batchId])
      sf=RedisFile.find(params[:fileId])
      od=DemanderTemp.find(params[:uuid])

      if bf and sf and od
        puts sf
        nd= DemanderTemp.new(:key=>od.key,:cpartNr=>params[:partNr],:clientId=>clientId,:supplierNr=>params[:supplierNr],
        :filedate=>params[:filedate],:date=>(FormatHelper::demand_date_by_str_type(params[:filedate],params[:type])),
        :type=>params[:type],:amount=>params[:amount],:lineNo=>od.lineNo,:source=>od.source)

        okey=od.gen_md5_repeat_key
        nkey=nd.gen_md5_repeat_key
        if okey!=nkey
           bf.del_repeat_item(od.gen_md5_repeat_key,od.key)
        end
        vmsg=DemanderHelper::demand_field_validate(nd,bf)
        nd.vali=vmsg.result

        if vmsg.result
          nd.rate=DemandHistory.compare_rate(
          nd.clientId,nd.supplierId,
          nd.cpartId,nd.type,nd.date,nd.amount)
          sf.update(:errorCount=> sf.errorCount-=1)
          if sf.errorCount==0
            bf.update(:errorCount=> bf.errorCount-=1)
          end
        else
        nd.msg=vmsg.contents.to_json
        end

        nd.cover

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

  # ws cancel upload
  def cancel_upload
    if request.post?
      msg=ReturnMsg.new(:result=>false,:content=>'')
      if batchFile=RedisFile.find(params[:batchId])
        Resque.enqueue(DemandUploadCanceler,batchFile.key)
        msg.result=true
        msg.content='cancel success'
      else
        msg.content='batch file not exists or has been canceled.'
      end
      respond_to do |format|
        format.xml {render :xml=>JSON.parse(msg.to_json).to_xml(:root=>'demandhistory')}
        format.json { render json: msg }
      end
    end
  end

  # ws demand history
  def demand_history
    if request.post?
      demandId=params[:demandId]
      startIndex=params[:startIndex].to_i
      endIndex=params[:endIndex].to_i
      msg=ReturnMsg.new(:result=>false,:content=>'')
      if demander=Demander.find(demandId)
        demander.gen_key
        keys= DemandHistory.get_demander_keys(demander.key,startIndex,endIndex)
        if keys.count>0
          msg.result=true
          msg.object=[]
          keys.each do |k|
            if dh=DemandHistory.find(k)
            msg.object<<dh
            end
          end
        else
          msg.content='no history'
        end
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
      @list = Organisation.option_list
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
      :amount=>params[:amount],
      :type=>params[:type] )
    demand.save
    demand.save_to_send
    end

    redirect_to root_path
  end

  def search

    @demands = []
    @demands = Demander.search( :client=>params[:client],
                                                      :supplier=>params[:supplier],
                                                      :rpartNr=>params[:partNr],
                                                      :start=>params[:start],
                                                      :end=>params[:end],
                                                      :type=>params[:type],
                                                      :page=>params[:page] )

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @demands }
    end
  end

# private
#
# # ws private get demands
# def get_demand_items type
#
# end

end