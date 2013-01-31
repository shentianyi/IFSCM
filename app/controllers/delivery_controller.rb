#encoding: utf-8
class DeliveryController < ApplicationController

  before_filter  :authorize
  # ws
  # 运单列表
  def index
  end

  # ws
  # 准备运单零件
  def pick_part
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
        dit=DeliveryItemTemp.new(:packAmount=>packAmount,:perPackAmount=>per,:partRelId=>metaKey,:spartNr=>params[:partNr],
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
      msg=ReturnMsg.new(:result=>false,:content=>'')
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
  # [功能：] 浏览待发运单
  # 参数：
  # - string ： dnKey
  # 返回值：
  # - ReturnMsg : JSON
  def view_pend_dn
    msg=ReturnMsg.new(:result=>false,:content=>'')
    if dn=DeliveryNote.rfind(params[:dnKey])
      st=Staff.find(dn.staff_id.to_i)
      if (st=Staff.find(dn.staff_id.to_i)) and st.orgId==session[:org_id]
        @currentPage=pageIndex=params[:pageIndex].nil? ? 0 : params[:pageIndex].to_i
        startIndex,endIndex=PageHelper::generate_page_index(pageIndex,$DEPSIZE)
        dn.items,@totalCount=DeliveryBll.get_delivery_detail dn.key,startIndex,endIndex
        if @totalCount
          @totalPages=PageHelper::generate_page_count @totalCount,$DEPSIZE
        msg.object=dn
        msg.result=true
        else
          msg.content="运单无内容"
        end
      else
        msg.content='此运单无权限查看'
      end
    else
      msg.content='运单不存在，请重新操作'
    end
    @msg=msg
    if request.post?
      dnItems=dn.nil? ? nil : dn.items
      respond_to do |format|
        format.xml {render :xml=>dnItems}
        format.json { render json: dnItems }
        format.html {render partial:'dn_pend_items',:locals=>{:dnItems=>dnItems}}
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
      msg=ReturnMsg.new(:result=>false,:content=>'')
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
      msg=ReturnMsg.new
      type=params[:printType]
      fileName= if type=='dn'
        DeliveryBll.generate_dn_label_pdf params[:dnKey],params[:destination],params[:sendDate]
      elsif type=="pack"
        DeliveryBll.generate_dn_pack_label_pdf params[:dnKey]
      end
      if fileName
        msg.result=true
        msg.content= AliBucket.url_for(fileName)
      end
      render :json=>msg
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
        dit.update(:packAmount=>packN,:perPackAmount=>per,
        :total=>FormatHelper.string_multiply(per,packN))
        msg.result=true
        msg.object=dit
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
end
