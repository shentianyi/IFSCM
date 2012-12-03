#coding:utf-8
class DemanderController<ApplicationController

  before_filter  :authorize
  # ws
  def demand_upload
    # to the view
  end

  # ws upload demands from csv -- support muti files
  def upload_files
    if request.get?
      else
      files=params[:files]
      begin
        msg=ReturnMsg.new(:result=>false,:content=>'')
        hfiles=[]
        if files.count>0
          files.each do |f|
            dcsv=FileData.new(:data=>f,:type=>FileDataType::CSVDemand,:oriName=>f.original_filename,:uuidName=>UUID.generate,:path=>$DECSVP)
            dcsv.saveFile
            hfiles<<dcsv
          end
          batchIndex=DemanderHelper::generate_batchFile_index(hfiles)
            msg.result=true
            msg.object=batchIndex
            #Resque.enqueue(DemandUpfilesDeler,batch_file.key)
        else
          msg.content='未选择文件'
        end
      rescue Exception => e
        msg.content=e.message+'//'+ e.backtrace.inspect
      end
      respond_to do |format|
        format.xml {render :xml=>JSON.parse(msg.to_json).to_xml(:root=>'filesInfo')}
        format.json { render json: msg }
        format.html {render partial:'upfile_unhandle_items',:locals=>{:msg=>msg}}
      end
    end
  end
  
  # ws handle batch file
  def handle_batch
    if request.post?
      batchFileId=params[:batchFileId]
      msg=DemanderHelper::handle_batchFile_from_csv(batchFileId,session[:org_id])
      if !msg.result
        Resque.enqueue(DemandUploadCanceler,batchFileId)
      else
          msg.object.add_to_staff_zset session[:staff_id]
        Resque.enqueue(DemandUpfilesDeler,batchFileId)
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
      demands=nil
      file=RedisFile.find(fileId)
      type='error'
      if file
        demands=[]
        type=file.errorCount.to_i>0 ? 'error':'normal'
        @currentPage=pageIndex=params[:pageIndex].to_i
        startIndex,endIndex=PageHelper::generate_page_index(pageIndex,$DEPSIZE)
        demands,@totalCount= DemanderHelper::get_file_demands fileId,startIndex,endIndex,type
        if demands.items.nil? # for error
              @currentPage=pageIndex=params[:pageIndex].to_i-1
              startIndex,endIndex=PageHelper::generate_page_index(pageIndex,$DEPSIZE)
             demands,@totalCount= DemanderHelper::get_file_demands fileId,startIndex,endIndex,type
        end
        @totalPages=PageHelper::generate_page_count @totalCount,$DEPSIZE
        @finished=file.finished
      end
      respond_to do |format|
        format.xml {render :xml=>JSON.parse(demands.to_json).to_xml(:root=>'demands')}
        format.json { render json: demands }
        format.html { render partial: type+'_items',:locals=>{:demands=>demands}}
      end
    end
  end

  # ws correct error
  def correct_error
    if request.post?
      clientId=session[:org_id]
      msg=ReturnMsg.new(:result=>false,:content=>'')
      bf,sf,od=RedisFile.find(params[:batchId]),RedisFile.find(params[:fileId]),DemanderTemp.find(params[:uuid])

      if bf and sf and od

        nd= DemanderTemp.new(:key=>od.key,:cpartNr=>params[:partNr],:clientId=>clientId,:supplierNr=>params[:supplierNr],
        :filedate=>params[:filedate],:date=>(FormatHelper::demand_date_by_str_type(params[:filedate],params[:type])),
        :type=>params[:type],:amount=>params[:amount],:lineNo=>od.lineNo,:source=>od.source)

        okey, nkey=od.gen_md5_repeat_key,nd.gen_md5_repeat_key
        if okey!=nkey
        bf.del_repeat_item(od.gen_md5_repeat_key,od.key)
        end
        vmsg=DemanderHelper::demand_field_validate(nd,bf)
        nd.vali=vmsg.result

        if vmsg.result
          nd.rate,nd.oldamount=DemandHistory.compare_rate(nd)
          if od.vali=='false'
            if sf.errorCount.to_i==1
              bf.update(:errorCount=> bf.errorCount.to_i-1)
            end
            sf.update(:errorCount=> sf.errorCount.to_i-1) 
          end
        else
          if od.vali=='true'
            if sf.errorCount.to_i==0
              bf.update(:errorCount=> bf.errorCount.to_i+1)
            end
            sf.update(:errorCount=> sf.errorCount.to_i+1)
          end
            nd.msg=vmsg.contents.to_json
        end

        nd.cover

        #move demand
        if nd.vali.to_s!=od.vali
          from=!nd.vali ? 'normal':'error'
          to=nd.vali ? 'normal':'error'
          score=nd.vali ? nd.rate.to_i.abs : nd.lineNo
          sf.send "move_#{from}_to_#{to}".to_sym,score,nd.key
        end
      msg.result=true
      
      nd.instance_variable_set :@sk,sf.key
      nd.instance_variable_set :@bk,bf.key
      nd.instance_variable_set :@sc,sf.errorCount
      nd.instance_variable_set :@bc,bf.errorCount
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
        if batchFile.finished=='false'
          RedisFile.remove_staff_cache_file session[:staff_id],batchFile.key
          Resque.enqueue(DemandUploadCanceler,batchFile.key)
          msg.result=true
          msg.content='取消成功'
        else
          msg.content='已经发送成功，不可取消'
        end
      else
        msg.content='上传已经取消'
      end
      respond_to do |format|
        format.xml {render :xml=>JSON.parse(msg.to_json).to_xml(:root=>'cancelMsg')}
        format.json { render json: msg }
      end
    end
  end

  # ws demand history
  def demand_history
    if request.post?
      demandId=params[:demandId]
      nt = Time.parse(params[:endIndex])
      if nt.hour+nt.min+nt.sec>0 
        if demander=Demander.find(demandId)
          nt = Time.at(DemandHistory.get_two_ends(demander).last.created_at.to_i)
          endIndex=Time.local(nt.year, nt.mon, nt.day).to_i + 1.day.to_i
          startIndex=endIndex - 3.day.to_i
         end
      else
        startIndex=Time.parse(params[:startIndex]).to_i
        endIndex=Time.parse(params[:endIndex]).to_i
      end
      
      # chart = [[startIndex,0],nil,[endIndex,0]]
      chart = []
      msg=ReturnMsg.new(:result=>false,:content=>'')
      if demander=Demander.find(demandId)
        if hs = DemandHistory.get_demander_hitories(demander,startIndex,endIndex)
          msg.result=true
          msg.object=hs
        else
          msg.content='no history'
          msg.object=[]
        end
        if right=DemandHistory.get_demander_hitories(demander,endIndex,Time.now.to_i)
          rchart = [[right.first.created_at.to_i, right.first.amount.to_s.to_num]]
        # elsif Time.now.to_i<endIndex
          # rchart = [[Time.now.to_i,hs.last.amount.to_s.to_num]]
        # else
          # rchart = [[endIndex,hs.last.amount.to_s.to_num]]
        else
          rchart = []
        end
        if left=DemandHistory.get_demander_hitories(demander,-(1/0.0),startIndex)
          lchart = [[left.last.created_at.to_i, left.last.amount.to_s.to_num]]
        else
          lchart = []
        end
        chart = lchart+msg.object.collect{|p| [p.created_at.to_i, p.amount.to_s.to_num] }+rchart
        lrmost = [] 
        scope = []
        DemandHistory.get_two_ends(demander).each {|e| lrmost<<Time.at(e.created_at.to_i) }
        scope<<Time.local(lrmost[0].year, lrmost[0].mon, lrmost[0].day).to_i if lrmost[0].hour+lrmost[0].min+lrmost[0].sec>0
        scope<<Time.local(lrmost[1].year, lrmost[1].mon, lrmost[1].day).to_i-2.day.to_i if lrmost[1].hour+lrmost[1].min+lrmost[1].sec>0
        partNr = session[:orgOpeType]==OrgOperateType::Client ? demander.cpartNr : demander.spartNr
      end
      xaxis = []
      5.times.each{|e| xaxis<<(startIndex+e.day.to_i) }
      x = xaxis.collect{|p| [p, FormatHelper::label_xaxis(p) ] }
      
      respond_to do |format|
        format.xml {render :xml=>JSON.parse(msg.to_json).to_xml(:root=>'demandHistory')}
        format.json { render json: {:msg=>msg, 
            :partNr=>partNr,
            :scope=>scope.collect{|p| FormatHelper::label_xaxis(p) },
            :chart=>chart,
            :x=>x,
            :xmin=>startIndex,
            :xmax=>endIndex
            } }
      end
    end
  end

  # download up demand files as zip
  def download
    if request.post?
      msg=DemanderHelper::zip_demand_cvs params[:batchFileId], request.user_agent
      if msg.result
        send_file msg.content,:type => 'application/zip', :filename => "#{UUID.generate}.zip"
        File.delete(msg.content)
      end
    end
  end

  def index
  end

  # ori: ding: create
  # rewrite: ws
  def send_demand
    if request.post?
      msg=ReturnMsg.new(:result=>false,:content=>'')
      batchId=params[:batchFileId]
      if bf=RedisFile.find(batchId)
        if bf.errorCount.to_i==0
          if bf.finished=='false'
            sfKeys,scount=bf.get_normal_item_keys 0,-1
            if scount>0

              sfKeys.each do |sk|
                if sf=RedisFile.find(sk) and sf.finished=='false'
                  nds,ncount=DemanderHelper::get_file_demands sf.key,0,-1,'normal'
                  if ncount>0
                    nds.items.each do |nd|
                      if tempKey = DemandHistory.exists( nd.clientId,nd.supplierId,nd.relpartId,nd.type,nd.date )
                        demand = Demander.find(tempKey)
                        demand.update( :clientId=>nd.clientId, :supplierId=>nd.supplierId, :relpartId=>nd.relpartId, :type=>nd.type, :date=>nd.date,
                        :amount=>nd.amount, :oldamount=>nd.oldamount, :rate=>nd.rate)
                        demand.save_to_send_update
                      else
                        demand = Demander.new( :key=>Demander.gen_key,
                        :clientId=>nd.clientId, :supplierId=>nd.supplierId, :relpartId=>nd.relpartId, :type=>nd.type, :date=>nd.date,
                        :amount=>nd.amount, :oldamount=>nd.oldamount, :rate=>nd.rate)
                        demand.save
                        demand.save_to_send
                      end
                      if nd.rate.to_i != 0 or nd.oldamount.nil?
                        Demander.send_kestrel(demand.supplierId, demand.key, demand.type)
                      end
                      demandH=DemandHistory.new(:key=>UUID.generate,:amount=>nd.amount,:rate=>nd.rate,:oldmount=>nd.oldamount,:demandKey=>demand.key)
                      demand.add_to_history demandH.key
                      demandH.save
                    end
                  end
                end
                sf.update(:finished=>true)
              end
              bf.update(:finished=>true)
              RedisFile.remove_staff_cache_file session[:staff_id],bf.key
              msg.result=true
              msg.content='发送成功'
            end
          else
            msg.content='预测已经发送成功，不可重复发送'
          end
        else
          msg.content='文件中仍存在错误，请更正以后再发送'
        end
      else
        msg.content='服务错误，请重新上传文件'
      end
      respond_to do |format|
        format.xml {render :xml=>JSON.parse(msg.to_json).to_xml(:root=>'sendMsg')}
        format.json { render json: msg }
      end
    end
  end
  
  def kestrel_newer
    if params[:type]
        render :json=>Demander.clear_kestrel(@cz_org.id)
    else
        dType={ ''=>0 }
        ['D','W','M','Y'].each{|e| dType[e]=Demander.get_kestrel(@cz_org.id, e, 0).last  and dType['']+=dType[e] }
        render :json=>dType.to_json
    end
  end

  def search
    if params[:kestrel] && params[:kestrel]==Rns::Kes
          @demands, @total = Demander.get_kestrel( @cz_org.id, params[:type], params[:page] )
          total=@total-@demands.size
          @totalPages=total/Demander::NumPer+(total%Demander::NumPer==0 ? 0:1)
          @currentPage=-1
          @options = params[:options]?params[:options]:{}
    else
            c = params[:client]
            s = params[:supplier]
            p = params[:partNr]
            tstart = Time.parse(params[:start]).to_i if params[:start] && params[:start].size>0
            tend = Time.parse(params[:end]).to_i if params[:end] && params[:end].size>0
        
            ######  判断类型 C or S ， 将session[:id]赋值给 id
        
            if session[:orgOpeType]==OrgOperateType::Client
              supplierId = @cz_org.search_supplier_byNr( s ) if s && s.size>0
              clientId = @cz_org.id
              partRelMetaKey = PartRel.get_all_partRelMetaKey_by_partNr( clientId, p, PartRelType::Client ) if p && p.size>0
            else
              clientId = @cz_org.search_client_byNr( c ) if c && c.size>0
              supplierId = @cz_org.id
              partRelMetaKey = PartRel.get_all_partRelMetaKey_by_partNr( supplierId, p, PartRelType::Supplier ) if p && p.size>0
            end
            partRelMetaKey = 'none' if partRelMetaKey && partRelMetaKey.size==0
            @demands = []
            @demands, @total = Demander.search( :clientId=>clientId, :supplierId=>supplierId,
            :rpartNr=>partRelMetaKey, :start=>tstart, :end=>tend,
            :type=>params[:type],  :amount=>params[:amount],
            :page=>params[:page] )
            @totalPages=@total/Demander::NumPer+(@total%Demander::NumPer==0 ? 0:1)
            @currentPage=params[:page].to_i
            @options = params[:options]?params[:options]:{}
    end
    # @totalPages=@total/Demander::NumPer+(@total%Demander::NumPer==0 ? 0:1)
    # @currentPage=params[:page].to_i
    # @options = params[:options]?params[:options]:{}

    respond_to do |format|
      format.html {render :partial=>"table" }
      format.json { render json: @demands }
    end
  end

  def data_analysis
    if request.post?
            p = params[:partNr]
            ######  判断类型 C or S ， 将session[:id]赋值给 id
            if session[:orgOpeType]==OrgOperateType::Client
              clientId = @cz_org.id
              partRelMetaKey = PartRel.get_all_partRelMetaKey_by_partNr( clientId, p, PartRelType::Client ) if p && p.size>0
            else
              supplierId = @cz_org.id
              partRelMetaKey = PartRel.get_all_partRelMetaKey_by_partNr( supplierId, p, PartRelType::Supplier ) if p && p.size>0
            end
            partRelMetaKey = 'none' if partRelMetaKey && partRelMetaKey.size==0
            @demands = []
            @demands, @total = Demander.search( :clientId=>clientId, :supplierId=>supplierId,
                                                                                        :rpartNr=>partRelMetaKey,
                                                                                        :page=>params[:page] )
            @totalPages=@total/Demander::NumPer+(@total%Demander::NumPer==0 ? 0:1)
            @currentPage=params[:page].to_i
            @options = params[:options]?params[:options]:{}
            render :partial=>"chart_table"
    else
    end
  end

  def data_chart
  end

  # ws : check unfinished batch file before page unload
  def check_staff_unfinished_file
    if request.post?
      batchId=params[:batchFileId]
      result=false
      if bf=RedisFile.find(batchId)
        puts 'check key:'+batchId
        puts 'fin:'+bf.finished
        if bf.finished=='false'
        result=true
        end
      end
      render :json=>{:result=>result}
    end
  end

  # ws : check cache file after page load
  def check_staff_cache_file
    if request.post?
      msg=ReturnMsg.new(:result=>false)
      if batchFileId=RedisFile.check_staff_cache_file(session[:staff_id])
      msg.result=true
      msg.object=batchFileId
      end
      render :json=>msg
    end
  end

  # ws : clean staff cache file
  def clean_staff_cache_file
    if request.post?
      batchId=params[:batchFileId]
      RedisFile.remove_staff_cache_file session[:staff_id],batchId
      Resque.enqueue(DemandUploadDataDiscarder,batchId)
      render :json=>{:msg=>'clean staff cache file'}
    end
  end

  # ws : get cache file info
  def get_cache_file_info
    if request.post?
      msg=ReturnMsg.new(:result=>false)
      if bf=DemanderHelper::get_batch_file_info(params[:batchFileId],0,-1)[0]
      msg.result=true
      msg.object=bf
      end
      respond_to do |format|
        format.xml {render :xml=>JSON.parse(msg.to_json).to_xml(:root=>'filesInfo')}
        format.json { render json: msg }
        format.html {render partial:'upfile_items',:locals=>{:msg=>msg}}
      end
    end
  end

end
