#encoding: utf-8
class DeliveryController < ApplicationController

  before_filter  :authorize
  before_filter :auth_dn,:only=>[:arrive,:mark_abnormal,:doinspect]
  before_filter :redis_auth_dn,:only=>[:dn_detail,:gen_dn_pdf,:accept,:doaccept,:receive,:inspect,:instore,:doinstore,:abnormal,:pack]
  ##
  # ws
  # 运单列表
  def index
  end

  # ws
  # 准备运单零件
  def pick_part
    if params[:c]
      @clientNr=params[:c]
    end
  end

  # ws
  # [功能：] 发送运单
  # 参数：
  # - string : dnKey
  # - string : destiStr
  # 返回值：
  # - ReturnMsg : JSON
  def send_delivery
    if request.post?
      if request.post?
        msg=DeliveryBll.send_dn session[:staff_id],params[:dnKey],params[:destiStr],params[:sendDate]
        render :json=>msg
      end
    end
  end

  # ws
  # [功能：] 获取运单项缓存 和 运单缓存
  # 参数：
  # - 无
  # 返回值：
  # - DeliveryItem & DeliveryNote : 运单项对象数组 & 运单对象数组
  def get_dit_dn_cache
    if request.post?
      cache={}
      cache[:dit]=DeliveryItemTemp.get_staff_cache(session[:staff_id])[0]
      cache[:dn]=DeliveryNote.get_all_staff_cache session[:staff_id]
      respond_to do |format|
        format.xml {render :xml=>JSON.parse(cache.to_json).to_xml(:root=>'cache')}
        format.json { render json: cache }
      end
    end
  end

  # ws
  # [功能：] 获取运单项缓存
  # 参数：
  # - 无
  # 返回值：
  # - DeliveryItem : 运单项对象数组
  def get_di_temp
    if request.post?
      temps=DeliveryItemTemp.get_staff_cache(session[:staff_id])[0]
      respond_to do |format|
        format.xml {render :xml=>JSON.parse(temps.to_json).to_xml(:root=>'temps')}
        format.json { render json: temps }
      end
    end
  end

  # ws
  # [功能：] 获取运单缓存
  # 参数：
  # - 无
  # 返回值：
  # - DeliveryNote : 运单对象数组
  def get_dn_cache
    if request.post?
      dns=DeliveryNote.get_all_staff_cache session[:staff_id]
      respond_to do |format|
        format.xml {render :xml=>dns}
        format.json { render json: dns }
      end
    end
  end

  # ws
  # [功能：] 添加运单项缓存
  # 参数：
  # - string : metaKey
  # - string : packAmount
  # - string : perPackAmount
  # 返回值：
  # - ReturnMsg : JSON
  def add_di_temp
    if request.post?
      packAmount=params[:packAmount]
      per=params[:perPackAmount]
      metaKey=params[:metaKey]
      msg=ReturnMsg.new
      valiMsg= DeliveryBll.vali_di_temp(metaKey,packAmount,per,session[:staff_id])
      msg.result=valiMsg.result
      if valiMsg.result
        dit=DeliveryItemTemp.new(:packAmount=>packAmount,:perPackAmount=>per,:part_rel_id=>metaKey,:spartNr=>params[:partNr],
        :total=>FormatHelper.string_multiply(per,packAmount))
        dit.save
        dit.add_to_staff_cache session[:staff_id]
      msg.object=dit
      else
      msg.content=valiMsg.content
      end
      respond_to do |format|
        format.xml {render :xml=>JSON.parse(msg.to_json).to_xml(:root=>'addDITempMsg')}
        format.json { render json: msg }
      end
    end
  end

  # ws
  # [功能：] 删除运单项缓存
  # 参数：
  # - string ： deliveryItemId
  # 返回值：
  # - ReturnMsg : JSON
  def delete_dit
    if request.post?
      msg=ReturnMsg.new
      tempKey=params[:tempKey]
      if dit=DeliveryItemTemp.find(tempKey)
        dit.delete_from_staff_cache session[:staff_id]
        dit.destroy
        msg.result=true
      else
        msg.content='运单缓存项不存在'
      end
      respond_to do |format|
        format.xml {render :xml=>JSON.parse(msg.to_json).to_xml(:root=>'delDITempMsg')}
        format.json { render json: msg }
      end
    end
  end

  # ws
  # [功能：] 取消用户运单
  # 参数：
  # - string ： dnKey
  # 返回值：
  # - ReturnMsg : JSON
  def cancel_staff_dn
    if request.post?
      msg=ReturnMsg.new
      if DeliveryNote.exist_in_staff_cache(session[:staff_id],params[:dnKey])
        if dn=DeliveryNote.single_or_default(params[:dnKey])
          dn.delete_from_staff_cache
          Resque.enqueue(DeliveryStaffCacheDiscarder,session[:staff_id],params[:dnKey])
        end
      msg.result=true
      else
        msg.content='运单已取消或已发送,不可再次取消'
      end
      render :json=>msg
    end
  end

  # ws
  # [功能：] 生成运单
  # 参数：
  # - 无
  # 返回值：
  # - ReturnMsg : JSON
  def build_dn
    if request.post?
      msg=DeliveryBll.build_delivery_note(session[:staff_id],session[:org_id],params[:desiOrgNr])
      respond_to do |format|
        format.xml {render :xml=>msg}
        format.json { render json: msg }
      end
    end
  end

  # ws
  # [功能：] 查看组织新运单数量
  # 参数：
  # - 无
  # 返回值：
  # - DeliveryNote : 对象数组
  def count_dn_queue
    if request.post?
      render :json=>{:count=>DeliveryNote.count_org_dn_queue(session[:org_id],session[:orgOpeType])}
    end
  end

  # ws
  # [功能：] 清空组织新运单
  # 参数：
  # - 无
  # 返回值：
  # - ReturnMsg : JSON
  def clean_dn_queue
    if request.post?
      msg=ReturnMsg.new
      msg.result=DeliveryNote.clean_org_dn_queue(session[:org_id],session[:orgOpeType])
      render :json=>msg
    end
  end

  # ws
  # [功能：] 查询运单
  # 参数：
  # - 无
  # 返回值：
  # - DeliveryNote : 对象数组
  def search_dn
    if request.post?
      @currentPage=pageIndex=params[:pageIndex].to_i
      startIndex,endIndex=PageHelper::generate_page_index(pageIndex,$DEPSIZE)
      dns,@totalCount=DeliveryBll.search_dn params[:condition],session[:org_id],session[:orgOpeType], startIndex,endIndex
      @totalPages=PageHelper::generate_page_count @totalCount,$DEPSIZE
      @condition=params[:condition]||{}
      respond_to do |format|
        format.xml {render :xml=>dns}
        format.json { render json: dns }
        format.html {render partial:'dn_list',:locals=>{:dns=>dns}}
      end
    end
  end

  # ws
  # [功能：] 运单模糊搜索
  # 参数：
  # - 无
  # 返回值：
  # - 运单号数组
  def redis_search_dn
    result = Redis::Search.complete("DeliveryNote", params[:term], :conditions=>{:orgIds=>session[:org_id]})
    dnKeys = result.collect{|item| item['title']}
    respond_to do |format|
      format.xml {render :xml=>JSON.parse(dnKeys.to_json).to_xml(:root=>'dnKeys')}
      format.json { render json: dnKeys }
      format.json { render text: dnKeys }
    end
  end

  # ws
  # [功能：] 打印运单标签
  # 参数：
  # - 无
  # 返回值：
  # - string : 文件地址
  def gen_dn_pdf
    if request.post?
      if @msg.result
      msg=DeliveryBll.generate_dn_label_pdf params[:dnKey],params[:printType].to_i,params[:destination],params[:sendDate]
      if msg.result
        @msg.content= AliBucket.url_for(msg.content)
      else
        @msg=msg
      end      
      end
      render :json=>@msg
    end
  end

  # ws
  # [功能：] 将运单放入客户端打印列表
  # 参数：
  # - string ： dnKey
  # 返回值：
  # - ReturnMsg : JSON
  def add_to_print
    if request.post?
      msg=ReturnMsg.new
      if dn=DeliveryNote.single_or_default(params[:dnKey])
        if dn.add_to_staff_print_queue
          msg.result=true
          msg.content="已添加到打印队列，使用客户端打印"
        else
          msg.content="已经添加到打印队列，不可重复添加"
        end
      end
      render :json=>msg
    end
  end

  # ws
  # [功能：] 更改运单缓存项
  # 参数：
  # - string ： dnKey
  # 返回值：
  # - ReturnMsg : JSON
  def update_dit
    if request.post?    
      msg=ReturnMsg.new  
      if dit=DeliveryItemTemp.find(params[:ditkey])
        per=params[:perPackAmount]
        packN=params[:packAmount]
        total=FormatHelper.string_multiply(per,packN)
        if dit.order_item_id and dit.rest.to_f<total
            msg.content="订单未发送量为:#{dit.rest},目前总量超出"
        else
          dit.update(:packAmount=>packN,:perPackAmount=>per,:total=>total)
            msg.result=true
            msg.object=dit
        end
      else
        msg.content="运单缓存项不存在"
      end
      render :json=>msg
    end
  end

  def check_dit_list
    @clientNr=params[:c]
    p=0
    if FormatHelper.str_is_positive_integer(params[:p]||0)
      p=params[:p].to_i
    end
    @currentPage=pageIndex=p
    startIndex,endIndex=PageHelper::generate_page_index(pageIndex,$DEPSIZE)
    @temps,@totalCount=DeliveryItemTemp.get_staff_cache(session[:staff_id],startIndex,endIndex)
    if @temps and @temps.count==0
       @currentPage=pageIndex=p-1
       startIndex,endIndex=PageHelper::generate_page_index(pageIndex,$DEPSIZE)
       @temps,@totalCount=DeliveryItemTemp.get_staff_cache(session[:staff_id],startIndex,endIndex)
    end
    @totalPages=PageHelper::generate_page_count @totalCount,$DEPSIZE
  end

  # ws
  # [功能：] 清空运单项缓存
  # 参数：
  # - 无
  # 返回值：
  # - 无
  def clean_dit
    if request.post?
      DeliveryItemTemp.clean_all_staff_cache session[:staff_id]
      redirect_to :action=>:pick_part
    end
  end
  
  # ws
  # [功能：] 浏览待发运单
  # 参数：
  # - string ： dnKey
  # 返回值：
  # - ReturnMsg : JSON
  def dn_detail
    if @msg.result
      @currentPage=pageIndex=params[:p].nil? ? 0 : params[:p].to_i
        startIndex,endIndex=PageHelper::generate_page_index(pageIndex,$DEPSIZE)
        @items,@totalCount=DeliveryBll.get_delivery_detail @dn.key,startIndex,endIndex
        if @totalCount
          @totalPages=PageHelper::generate_page_count @totalCount,$DEPSIZE
        @msg.object=@dn
        @msg.result=true
        else
          @msg.result=false
          @msg.content="运单无内容"
        end
    end
    @type=params[:t]
    if params[:t]=="p"
      orl= OrganisationRelation.where("origin_client_id = ? and origin_supplier_id = ? ", @dn.rece_org_id, @dn.organisation_id).first
      @contacts=DnContact.all(orl.id).collect{|c| [c.rece_address,c.key]}
      render "view_pend_dn"
    elsif params[:t]=="d"
      render "dn_detail"
    end
  end
  
  ##-----------------------------------delivery accept----------------------
  # ws
  # [功能：] 显示运单接收页＆接收或拒收
  # 参数：
  # - string ： dnKey
  # 返回值：
  # - html
  def accept        
    Strategy
      @params={:dnKey=>params[:dnKey]}
     if @msg and @msg.result
       if @dn.can_accept
          @list=DeliveryBll.get_dn_list params[:dnKey],false
          if @list.count>0
          @inspects=DeliveryObjInspectState.all.collect{|r| [r.desc,r.value]}[1..-1]
        else
          @msg.result=false
          @msg.content="此运单不存在需接收零件"
       end
       else
         @msg.result=false
         @msg.content="运单：#{DeliveryObjWayState.get_desc_by_value(@dn.wayState)}，不可接收或设置到达"
       end
       end
  end
  
  # ws
  # [功能：] 执行运单接收
  # 参数：
  # - string ： dnKey
  # 返回值：
  # - html
  def doaccept
     if request.post?
      if @msg.result
        if @dn.can_doaccept
      ids=params[:ids].split(',')
      type=params[:type].to_i
      Resque.enqueue(DeliveryItemAccepter,ids,@dn.id,type)       
      @msg.object=DeliveryObjWayState.get_desc_by_value(type)
      @msg.content="已操作"
      else
         @msg.result=false
         @msg.content="运单：#{DeliveryObjWayState.get_desc_by_value(@dn.wayState)}，不可接收"
      end
      end
      render :json=>@msg      
    end
  end
  # ws
  # [功能：] 标记包装箱异常
  # 参数：
  # - string : ids
  # 返回值：
  # - html
  def mark_abnormal
    if request.post?
      if @msg.result
       ids=params[:ids].split(',')
        Resque.enqueue(DeliveryItemAllUpdater,100,ids,{:state=>DeliveryObjState::Abnormal})
        @dn.update_attributes(:state=>DeliveryObjState::Abnormal)   
        DeliveryItemState.where(:delivery_item_id=>ids).update_all(:state=>params[:type],:desc=>params[:desc]||"检验通过")  
        @msg.object=DeliveryObjState::Abnormal
        @msg.content=DeliveryObjState.get_desc_by_value(DeliveryObjState::Abnormal)
      end
      render :json=>@msg
    end
  end
  
  # ws
  # [功能：] 将运单置为“已到达”
  # 参数：
  # - string ： dnKey
  # 返回值：
  # - ReturnMsg : JSON
  def arrive
    if @msg.result
      if @dn.wayState==DeliveryObjWayState::Intransit
        @dn.update_attributes(:wayState=>DeliveryObjWayState::Arrived)  
        Resque.enqueue(DeliveryNoteWayStateStateUpdater,@dn.id)
        set_way_state_code(DeliveryObjWayState::Arrived)      
      else
        @msg.result=false
        @msg.content="运单：#{DeliveryObjWayState.get_desc_by_value(@dn.wayState)}，不可再次到达"
      end
    end
    render :json=>@msg
  end
  
  # ws
  # [功能：] 显示运单质检页
  # 参数：
  # - string ： dnKey
  # 返回值：
  # - html
  def inspect
      @params={:dnKey=>params[:dnKey]}
      if @msg and @msg.result
        if @dn.can_inspect
       @list=DeliveryBll.get_dn_check_list_from_mysql({:dnKey=>@dn.key,:needCheck=>true})
       if @list.count>0
          @inspects=DeliveryObjInspectState.all.collect{|r| [r.desc,r.value]}[1..-1]
        else
          @msg.result=false
          @msg.content="此运单不存在需质检零件"
       end
       else
         @msg.result=false
         @msg.content="<div>运单状态为:#{DeliveryHelper.get_dn_wayState(@dn.wayState)},处于不可质检状态。</br>只有运单处于:<span class='received'>#{DeliveryHelper.get_can_inspect_states.join('、')}</span>后才可质检。</div>"
       end
      end
  end
 
  # ws
  # [功能：] 执行运单质检
  # 参数：
  # - string ： dnKey
  # 返回值：
  # - html
  def doinspect
     if request.post?
      if @msg.result        
        type=params[:type].to_i
        ids=params[:ids].split(',')
        if type==DeliveryObjInspectState::Normal
          itemState=@msg.object=DeliveryObjState::Normal          
        elsif type!=DeliveryObjInspectState::Normal
          itemState=@msg.object=DeliveryObjState::Abnormal
          if params[:return]        
             Resque.enqueue(DeliveryItemReturner,ids,@dn.id)
             set_way_state_code(DeliveryObjWayState::Returned)                    
          end            
          @dn.update_attributes(:state=>itemState)           
        end             
        @msg.content=DeliveryObjState.get_desc_by_value(@msg.object)   
        state={:state=>type,:desc=>params[:desc]||"检验通过"}
        attrs={:checked=>true,:state=>itemState}
        Resque.enqueue(DeliveryItemInspector,100,ids,@dn.id,attrs,state)      
      end
      render :json=>@msg
      end
  end 
  
  def instore    
    @wares=Warehouse.selection_list(@cz_org)
    @params={:dnKey=>params[:dnKey],:type=>params[:type],:ware=>params[:ware]}
    if @msg and @msg.result
      if @dn.can_instore
        p={:dnKey=>@dn.key}
        t=params[:type].to_i
        if t==1
          p[:needCheck]=false
        elsif t==2
          p[:needCheck]=true
        end
        @list=DeliveryBll.get_dn_check_list_from_mysql(p)
        if @list.length==0
          @msg.result=false
          @msg.content="无需入库包装箱"
       end
       else
         @msg.result=false
         @msg.content="运单：#{DeliveryObjWayState.get_desc_by_value(@dn.wayState)}，不可入库"
       end
    end
  end
  
  def doinstore
    if request.post?
      if @msg.result   
        if item=DeliveryBll.get_dn_instore_item(params[:id])
         @msg=WarehouseBll.dn_item_move_by_item_id(params[:posiNr],params[:ware],item.id)
         otd=OnTimeDelivery.new(:amount=>item.amount,:part_rel_id=>item.part_rel_id)
         otd.save
         otd.update_otd_record
         if @msg.result
           item.update_attributes(:posi=>params[:posiNr],:stored=>true)
           Resque.enqueue(DeliveryNoteWayStateRoleMachine,@dn.id,DeliveryRoleMachineAction::DoStore)
         end
        else
            @msg.result=false
            @msg.content="包装箱已入库或不存在"
        end
      end
      render :json=>@msg
    end
  end
  
  # def return_dn
    # if request.post?
      # if @msg.result
       # if @dn.can_inspect
        # list=@dn.delivery_items
        # items=Hash[list.collect{|i| [i.id,i.key]}]
        # denied=Storage.return_denied(items.keys)
        # if denied              
           # @msg.result=false
           # @msg.object=items.delete_if{|k,v| !denied.include?(k)}
         # else
           # @dn.update_attributes(:wayState=>DeliveryObjWayState::Returned)
           # Resque.enqueue(DeliveryNoteWayStateStateUpdater,@dn.id)
           # set_way_state_code(DeliveryObjWayState::Returned)
        # end
        # else
          # @msg.result=false
          # @msg.content="运单：#{DeliveryObjWayState.get_desc_by_value(@dn.wayState)}，处于不可退货状态"
        # end
      # end      
    # render :json=>@msg
    # end
  # end
  
  def link
      @list=DeliveryBll.get_all_org_role_dn(session[:org_id],params[:r])
      @action=get_delivery_link_action(params[:r].to_i)
  end
  
  
  def abnormal
    if @msg.result     
      @list=DeliveryBll.get_dn_abnormal_pack(params[:id].to_i)
      render :layout => "window"
    end
  end
  
  def item_state
    state=DeliveryItemState.where(:delivery_item_id=>params[:id]).first
     respond_to do |format|
      format.json { render json: state }
      format.html {render partial:'state_info_card',:locals=>{:state=>state}}
    end
  end
  
   def pack
    if @msg.result     
      @list=DeliveryBll.get_pack_by_batch_id(params[:id].to_i)
      render :layout => "window"
    end
  end
  private 
  def auth_dn
    if params[:dnKey]     
     @dn=DeliveryNote.single_or_default(params[:dnKey],true)
     p_auth_dn
     end
  end
  
    def redis_auth_dn  
       if params[:dnKey]        
      @dn=DeliveryNote.single_or_default(params[:dnKey])
      p_auth_dn
      end
     end
  
  def p_auth_dn
    @msg=ReturnMsg.new
    if @dn
      if @dn.organisation_id==session[:org_id] or @dn.rece_org_id==session[:org_id]       
        @msg.result=true
      else
        @msg.content='此运单无权限查看'
      end
    else
      @msg.content='运单不存在'
    end
  end
  def set_way_state_code code
      @msg.instance_variable_set "@wayState",DeliveryObjWayState.get_desc_by_value(code)
      @msg.instance_variable_set "@wayStateCode",code
  end
  
  def get_delivery_link_action code
   action=case code
     when OrgRoleType::DnReciver
       "accept"
     when OrgRoleType::DnInspector
       "inspect"
     when OrgRoleType::DnInstorer
       "instore"
     end   
     return action
  end
end
