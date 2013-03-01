#encoding: utf-8
require 'org_rel_info'

class OrganisationManagerController < ApplicationController

  before_filter  :authorize
  def new
    if request.get?
      @org = Organisation.new()
    elsif request.post?
      @org = Organisation.new(:name=>params[:name], :description=>params[:description],
              :address=>params[:address], :tel=>params[:tel], :website=>params[:website],
              :abbr=>params[:abbr], :contact=>params[:contact], :email=>params[:email])
      if @org.save
        render :json=>{flag:true,msg:"新建成功！"}
      else
        render :json=>{flag:false,msg:"失败！"}
      end
    end
  end

  def index
    if params[:id].nil?
      @org = @cz_org
    else
      @org = Organisation.find(params[:id])
    end
  end

  def edit
    if request.get?
      @org = Organisation.find_by_id(params[:id])
      render :partial => "edit"
    elsif request.post?
      if org = Organisation.find_by_id(params[:id])  and
      org.update_attributes(:name=>params[:name], :description=>params[:description],
      :address=>params[:address], :tel=>params[:tel], :website=>params[:website],
      :abbr=>params[:abbr], :contact=>params[:contact], :email=>params[:email])
        render :json=>{flag:true,msg:"修改成功"}
      else
        render :json=>{flag:false,msg:"修改失败"}
      end
    end
  end

  def manager
    @list = Organisation.all.map {|o| [o.name, o.id] }
  end

  def create_staff
    if !s=Staff.where(:staffNr=>params[:staffNr],:orgId=>params[:orgId],:organisation_id=>params[:orgId]).first
      st=Staff.new(:staffNr => params[:staffNr], :name=>params[:name], :orgId=>params[:orgId],:password => params[:pass], :organisation_id=>params[:orgId],
      :password_confirmation => params[:conpass])
      if st.save
        render :json=>{flag:true,msg:"新建成功！"}
      else
        render :json=>{flag:false,msg:"失败！"}
      end
    else
      render :json=>{flag:false,msg:"失败！此号已存在。"}
    end
  end
  
  def create_costcenter
    unless cc=CostCenter.where(:name=>params[:ccName],:organisation_id=>params[:orgId]).first
      st=CostCenter.new(:name=>params[:ccName],:desc=>params[:ccDesc],:organisation_id=>params[:orgId])
      if st.save
        render :json=>{flag:true,msg:"新建成功！"}
      else
        render :json=>{flag:false,msg:"失败！"}
      end
    else
      render :json=>{flag:false,msg:"失败！不可重复建立。"}
    end
  end

  def create_org_relation
    orgrel = OrganisationRelation.new(:clientNr=>params[:clientNr], :supplierNr=>params[:supplierNr],
    :origin_supplier_id=>params[:supplierId], :origin_client_id=>params[:clientId])
    if OrganisationRelation.where("origin_client_id = ? and origin_supplier_id = ? ", orgrel.origin_client_id, orgrel.origin_supplier_id).first
      render :json=>{flag:false,msg:"失败！关系已存在，不可重复建立。"}
    elsif orgrel.save
      render :json=>{flag:true,msg:"新建成功"}
    else
      render :json=>{flag:false,msg:"失败！"}
    end
  end

  def create_relpart
    files=params[:files]
    result = true
    info = ""
    if files.size==1
      f = files.first
      dcsv=FileData.new(:data=>f,:type=>FileDataType::CSVPartRel,:oriName=>f.original_filename,:path=>$DETMP)
      dcsv.saveFile
      hfile = File.join($DETMP,dcsv.pathName)
      i=0
      CSV.foreach(hfile,:headers=>true,:col_sep=>$CSVSP) do |row|
        if row["Client"] and row["Supplier"] and row["CpartNr"] and row["SpartNr"] and row["SaleNo"] and row["PurchaseNo"]
          next unless cli = Organisation.where(:abbr=>row["Client"]).first
          next unless sup = Organisation.where(:abbr=>row["Supplier"]).first
          next unless orgrel = OrganisationRelation.where("origin_client_id = ? and origin_supplier_id = ? ", cli.id, sup.id).first
          unless cpart = Part.where("organisation_id = ? and partNr = ?", cli.id, row["CpartNr"]).first
            cpart = Part.new(:partNr=>row["CpartNr"])
          cli.parts<<cpart
          end
          unless spart = Part.where("organisation_id = ? and partNr = ?", sup.id, row["SpartNr"]).first
            spart = Part.new(:partNr=>row["SpartNr"])
          sup.parts<<spart
          end
          pr = PartRel.new(:saleNo=>row["SaleNo"], :purchaseNo=>row["PurchaseNo"], :client_part_id=>cpart.id, :supplier_part_id=>spart.id, :organisation_relation_id=>orgrel.id)
        i+=1 if pr.save
        else
          result = false
          info="缺少列值或文件标题错误,请重新修改上传！"
        end
      end
      info = "导入#{i}条。"
      File.delete(hfile)
    else
      result = false
      info = "文件数量不符合！"
    end

    if result
      render :json=>{flag:true,msg:"新建成功！"+info}
    else
      render :json=>{flag:false,msg:"失败！"+info}
    end
  end

  def create_relpart_package
    files=params[:files]
    result = true
    info = ""
    if files.size==1
      f = files.first
      dcsv=FileData.new(:data=>f,:type=>FileDataType::CSVRelpartPackage,:oriName=>f.original_filename,:path=>$DETMP)
      dcsv.saveFile
      hfile = File.join($DETMP,dcsv.pathName)
      i=0
      CSV.foreach(hfile,:headers=>true,:col_sep=>$CSVSP) do |row|
        if row["Client"] and row["Supplier"] and row["CpartNr"] and row["SpartNr"] and row["Least"]
          next unless cli = Organisation.where(:abbr=>row["Client"]).first
          next unless sup = Organisation.where(:abbr=>row["Supplier"]).first
          next unless orgrel = OrganisationRelation.where("origin_client_id = ? and origin_supplier_id = ? ", cli.id, sup.id).first
          next unless cpart = Part.where("organisation_id = ? and partNr = ?", cli.id, row["CpartNr"]).first
          # next unless spart = Part.where("organisation_id = ? and partNr = ?", sup.id, row["SpartNr"]).first
          next unless pr = PartRel.where(:client_part_id=>cpart.id,  :organisation_relation_id=>orgrel.id).first
          package = PackageInfo.new(:leastAmount=>row["Least"], :part_rel_id=>pr.id)
        i+=1 if package.save
        else
          result = false
          info="缺少列值或文件标题错误,请重新修改上传！"
        end
      end
      info = "导入#{i}条。"
      File.delete(hfile)
    else
      result = false
      info = "文件数量不符合！"
    end

    if result
      render :json=>{flag:true,msg:"新建成功"+info}
    else
      render :json=>{flag:false,msg:"失败！"+info}
    end
  end

  def create_relpart_check
    files=params[:files]
    result = true
    info = ""
    if files.size==1
      f = files.first
      dcsv=FileData.new(:data=>f,:type=>FileDataType::CSVRelpartCheck,:oriName=>f.original_filename,:path=>$DETMP)
      dcsv.saveFile
      hfile = File.join($DETMP,dcsv.pathName)
      i=0
      CSV.foreach(hfile,:headers=>true,:col_sep=>$CSVSP) do |row|
        if row["PartNr"] and row["Supplier"] and row["Date"] and row["Type"] and row["Amount"] and row["ddd"]
          else
          result = false
          info="缺少列值或文件标题错误,请重新修改上传！"
        end
      end
      info = "导入#{i}条。"
      File.delete(hfile)
    else
      result = false
      info = "文件数量不符合！"
    end

    if result
      render :json=>{flag:true,msg:"新建成功"}
    else
      render :json=>{flag:false,msg:"失败！"+info}
    end
  end

  def search
    if request.post?
      cs = params[:csNr]
      @organs = []
      if session[:orgOpeType]==OrgOperateType::Client
        cs = cs.present? ?  cs : "none"
        @search = Redis::Search.complete("OrganisationRelation", cs, :conditions=>{:origin_client_id=>@cz_org.id} )  ||[]
        @organs = @search.collect{|item| [ item["supplierNr"], Organisation.find_by_id(item['origin_supplier_id'].to_i) ]  }
      else
        cs = cs.present? ?  cs : "none"
        @search = Redis::Search.complete("OrganisationRelation", cs, :conditions=>{:origin_supplier_id=>@cz_org.id} ) ||[]
        @organs = @search.collect{|item| [ item["clientNr"], Organisation.find_by_id(item['origin_client_id'].to_i) ]  }
      end
      @total = @organs.size
      s = params[:page].to_i*Demander::NumPer
      e = params[:page].to_i*Demander::NumPer+Demander::NumPer-1
      @orgs = @organs[s..e]
      puts @orgs
      @totalPages=@total/Demander::NumPer+(@total%Demander::NumPer==0 ? 0:1)
      @currentPage=params[:page].to_i
      @options = params[:options]?params[:options]:{}

      render :partial=>'searchlist'
    else
    end

  end

  #################  for Fuzzy Search
  def redis_search
    if params[:term].blank?
      render :text => ""
    return
    end
    params[:term].gsub!(/'/,'')
    if session[:orgOpeType]==OrgOperateType::Client
      @search = Redis::Search.complete("OrganisationRelation", params[:term], :conditions=>{:origin_client_id=>@cz_org.id} )
    else
      @search = Redis::Search.complete("OrganisationRelation", params[:term], :conditions=>{:origin_supplier_id=>@cz_org.id} )
    end
    if params[:getId]
      lines = @search.collect{|item| {:csNr=>item['title'],:org=>item['id']}}
    elsif session[:orgOpeType]==OrgOperateType::Client
      lines = @search.collect{|item|item['supplierNr'] }
    else
      lines = @search.collect{|item|item['clientNr'] }
    end
    respond_to do |format|
      format.xml {render  xml:lines}
      format.json { render json: lines }
      format.json { render text: lines }
    end
  # render :text => lines
  end
  #**********************************************************************************************
  #__________________________________________delivery info set__________________________________
  def delivery_set
    @list = Organisation.all.map {|o| [o.name, o.id] }
    @priterTypes=OrgRelPrinterType.all.collect{|t| [t.desc,t.value]}
    @contactType=OrgRelContactType.all.collect{|t| [t.desc,t.value]}
  end

  def get_printer
    cli=Organisation.find(params[:cid])
    sup=Organisation.find(params[:sid])
    orl= OrganisationRelation.where("origin_client_id = ? and origin_supplier_id = ? ", cli.id, sup.id).first
    ps=OrgRelPrinter.all(orl.id,params[:ptype])
    dp=OrgRelPrinter.get_default_printer(orl.id,params[:ptype])
    render :text=>{:printers=>ps.to_json,:defaultPrinter=>dp.to_json}
  end

  def add_printer
    cli=Organisation.find(params[:cid])
    sup=Organisation.find(params[:sid])
    orl= OrganisationRelation.where("origin_client_id = ? and origin_supplier_id = ? ", cli.id, sup.id).first
    type=params[:ptype]
    printer=OrgRelPrinter.new(:org_rel_id=>orl.id,:template=>params[:template],
    :moduleName=>params[:moduleName],:type=> type,:updated=>true)
    printer.add_to_printer
    printer.save
    render :json=>{:msg=>"DONE!!!"+printer.key}
  end

  def del_printer
    printer=OrgRelPrinter.find(params[:printerKey])
    printer.destroy
    render :json=>{:msg=>"DONE!!!"+printer.key}
  end
  
  def update_default_printer
     printer=OrgRelPrinter.find(params[:printerKey])
    printer.update(:updated=>params[:updated])
    render :json=>{:msg=>"DONE!!!"+printer.key}
  end

  def add_default_printer
    printer=OrgRelPrinter.find(params[:printerKey])
    printer.add_to_dpriter
    render :json=>{:msg=>"DONE!!!"+printer.key}
  end

  def upload_printer_template
    files=params[:files]
    msg=ReturnMsg.new
    begin
    if files.size==1
      f = files.first
      template=FileData.new(:data=>f,:oriName=>f.original_filename,:path=>$PRINTERTEMPLATEPATH,:pathName=>f.original_filename)
      template.saveFile      
      path=File.join($PRINTERTEMPLATEPATH,template.pathName)
      AliDnPrintTemplateBuket.store(template.pathName,open(path))
      msg.result=true
      msg.content=f.original_filename+"，上传成功"
    else
      msg.content = "文件数量只可为1！"
    end
    rescue Exception=>e
      msg.content=e.message
    end
    render :json=>{:flag=>msg.result,:msg=>msg.content}
  end
  
  def get_dncontact
    cli=Organisation.find(params[:cid])
    sup=Organisation.find(params[:sid])
    orl= OrganisationRelation.where("origin_client_id = ? and origin_supplier_id = ? ", cli.id, sup.id).first
    c=eval(OrgRelContactBase.class_name_converter(params[:ctype].to_i)).find_by_orid(orl.id)
    s=""
    c.instance_variables.each do |attr|
        s+="  "+attr.to_s+":"+c.instance_variable_get(attr)
      end
    render :text=>s
  end

  def add_dncontact
    cli=Organisation.find(params[:cid])
    sup=Organisation.find(params[:sid])
    orl= OrganisationRelation.where("origin_client_id = ? and origin_supplier_id = ? ", cli.id, sup.id).first
    c= eval(OrgRelContactBase.class_name_converter(params[:ctype].to_i)).new(:org_rel_id=>orl.id,:type=>params[:ctype].to_i ,
    :recer_name=>params[:recer_name],
    :recer_contact=>params[:recer_contact],
    :rece_address=>params[:rece_address],
    :sender_name=>params[:sender_name],:sender_contact=>params[:sender_contact],
    :send_adderss=>params[:send_adderss])
    c.add_to_contact
    c.save
    render :json=>{:msg=>"DONE!!!"+c.key}
  end

  def del_dncontact
   cli=Organisation.find(params[:cid])
    sup=Organisation.find(params[:sid])
    orl= OrganisationRelation.where("origin_client_id = ? and origin_supplier_id = ? ", cli.id, sup.id).first
    c=DnContact.find_by_orid(orl.id)
   c.destroy
   render :json=>{:msg=>"DONE!!!"+c.key}
  end

end
