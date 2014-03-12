#encoding:utf-8
require 'org_rel_info'

module TPrinter
  def self.print_dn_pdf type,dnKey=nil
    msg=ReturnMsg.new
    begin
      printer,dataset=generate_dn_print_data(dnKey,type)
      msg=Wcfer::PdfPrinter.generate_dn_pdf(printer.template,dataset)
    rescue DataMissingError=>e
      msg.content=e.message
    rescue NoMethodError=>e
    puts e.message
      msg.content="打印机模板未设置，联系系统供应商进行设置"
    rescue Exception=>e
      puts e.message
      msg.content="打印服务错误，请联系系统供应商"
    end
    return msg
  end

  def self.print_pre_dn_check_pdf type,staff_id
    msg=ReturnMsg.new
    puts '------------------------'
    begin
      printer,dataset=generate_pre_dn_check_print_data(type,staff_id)
      msg=Wcfer::PdfPrinter.generate_dn_pdf(printer.template,dataset)
    rescue DataMissingError=>e
      msg.content=e.message
    rescue NoMethodError=>e
      msg.content="打印机模板未设置，联系系统供应商进行设置"
    rescue Exception=>e
      puts e.message
      msg.content="打印服务错误，请联系系统供应商"
    end
    return msg
  end

  def self.generate_dn_print_data dnKey,type
    dn,orl=get_dn_orl(dnKey)
    printer=OrgRelPrinter.get_default_printer(orl.id,type)
    dataset = eval(printer.moduleName.camelize).send :gen_data,dn,orl
    return printer,dataset
  end

  def self.generate_dn_item_print_data dnKey,type,diKeys=nil
    dn,orl=get_dn_orl(dnKey)
    printer = OrgRelPrinter.get_default_printer(orl.id,type)
    dataset = eval(printer.moduleName.camelize).send :gen_data,dn,orl,diKeys
    return printer,dataset
  end

  def self.generate_pre_dn_check_print_data type,staff_id
    if staff=Staff.find_by_id(staff_id)
      printer= OrgPrinter.get_default_printer(staff.organisation.id,type)
      dataset = eval(printer.moduleName.camelize).send :gen_data,staff_id
    return printer,dataset
    end
  end

  private

  def self.get_dn_orl dnKey
    dn=DeliveryNote.single_or_default(dnKey)
    return dn, OrganisationRelation.where(:origin_supplier_id=>dn.organisation_id,:origin_client_id=>dn.rece_org_id).first
  end
end