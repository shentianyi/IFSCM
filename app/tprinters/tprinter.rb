#coding:utf-8
require 'org_rel_info'

module TPrinter
  def self.print_dn_pdf dnKey,type
    msg=ReturnMsg.new
    begin
      printer,dataset=generate_dn_print_data(dnKey,type)
      result=Wcfer::PdfPrinter.generate_dn_pdf(printer.template,dataset,dnKey)
      msg.result= result[:result]
      msg.content=result[:content]
    rescue NoMethodError=>e
      puts e.message
      puts e.backtrace
      msg.content="打印机模板未设置，联系系统供应商进行设置"
    rescue Excetion=>e
      msg.content="打印服务错误，请联系系统供应商"
    end
    return msg
  end

  def self.print_dn_pack_list_pdf dnKey
    printer,dataset=generate_dn_pack_list_print_data dnKey
    return Wcfer::PdfPrinter.generate_dn_pdf(printer.template,dataset,dnKey)
  end

  def self.generate_dn_print_data dnKey,type
    dn,orl=get_dn_orl(dnKey)
    printer=OrgRelPrinter.get_default_printer(orl.id,type)
    dataset = eval(printer.moduleName.camelize).send :gen_data,dn,orl
    return printer,dataset
  end

  def self.generate_dn_item_print_data dnKey,diKeys=nil
    dn,orl=get_dn_orl(dnKey)
    printer = OrgRelPrinter.get_default_printer(orl.id,OrgRelPrinterType::DPackPrinter)
    dataset = eval(printer.moduleName.camelize).send :gen_data,dn,orl,diKeys
    return printer,dataset
  end

  private

  def self.get_dn_orl dnKey
    dn=DeliveryNote.single_or_default(dnKey)
    return dn, OrganisationRelation.where(:origin_supplier_id=>dn.organisation_id,:origin_client_id=>dn.rece_org_id).first
  end

end