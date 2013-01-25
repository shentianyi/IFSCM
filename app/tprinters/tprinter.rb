#coding:utf-8
require 'org_rel_info'

module TPrinter
  def self.print_dn_pdf dnKey
    dn=DeliveryNote.single_or_default(dnKey)
    orl = OrganisationRelation.where(:origin_supplier_id=>dn.organisation_id,:origin_client_id=>dn.rece_org_id).first
    printer=OrgRelPrinter.get_default_printer(orl.id,OrgRelPrinterType::DNPrinter)
    dataset = eval(printer.moduleName.camelize).send :gen_data,dn,orl
    return Wcfer::PdfPrinter.generate_dn_pdf(printer.template,dataset.to_json,dnKey)
  end
end