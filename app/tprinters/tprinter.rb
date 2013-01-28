#coding:utf-8
require 'org_rel_info'

module TPrinter
  def self.print_dn_pdf dnKey
    puts '__________________________'
    printer,dataset=generate_dn_print_data(dnKey)
    puts "printer:#{printer.to_json}"
    return Wcfer::PdfPrinter.generate_dn_pdf(printer.template,dataset.to_json,dnKey)
  end

  def self.print_dn_item_pdf dnKey

  end

  def self.generate_dn_print_data dnKey
    dn,orl=get_dn_orl(dnKey)
    printer=OrgRelPrinter.get_default_printer(orl.id,OrgRelPrinterType::DNPrinter)
    dataset = eval(printer.moduleName.camelize).send :gen_data,dn,orl
    return printer,dataset
  end

  def self.generate_dn_item_print_data dnKey
    dn,orl=get_dn_orl(dnKey)
    printer = OrgRelPrinter.get_default_printer(orl.id,OrgRelPrinterType::DPackPrinter)
    dataset = eval(printer.moduleName.camelize).send :gen_data,dn,orl
    return printer,dataset
  end

  private

  def self.get_dn_orl dnKey
   dn=DeliveryNote.single_or_default(dnKey)
   return dn, OrganisationRelation.where(:origin_supplier_id=>dn.organisation_id,:origin_client_id=>dn.rece_org_id).first
  end

end