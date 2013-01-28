#encoding: utf-8
require 'enum/org_rel_contact_type'
require 'enum/org_rel_printer_type'
require 'org_rel_info'

class AddOrgRelInfos
  def self.add_printer args
    printer=OrgRelPrinter.new(args)
    printer.add_to_printer
    printer.add_to_dpriter
    printer.save
  end

  def self.add_dn_contact args
    dncontact=DnContact.new(args)
    dncontact.add_to_contact
    dncontact.save
  end
end

orl = OrganisationRelation.where(:origin_client_id=>1,:origin_supplier_id=>3).first
# add dn printer
pargs={:org_rel_id=>orl.id,:tempalte=>"Leoni_Nbtp_DNTemplete.tff",
  :moduleName=>"leoni_nbtp_dn",:type=> OrgRelPrinterType::DNPrinter}

AddOrgRelInfos.add_printer pargs
# add dpack printer
pargs={:org_rel_id=>orl.id,:tempalte=>"Leoni_Nbtp_DPackTemplete.tff",
  :moduleName=>"leoni_nbtp_dpack",:type=> OrgRelPrinterType::DPackPrinter}
AddOrgRelInfos.add_printer pargs

# add dn contact
cargs={:org_rel_id=>orl.id,:type=> OrgRelContactType::DContact,
  :recer_name=>"原材料仓库",:recer_contact=>"39939591",:sender_name=>"王英",:sender_contact=>"0574-86883025"}
AddOrgRelInfos.add_dn_contact cargs
# OrgRelPrinter.find("OrgRelPrinter:1").add_to_dpriter
# OrgRelPrinter.find("OrgRelPrinter:2").add_to_dpriter
# DnContact.find("DnContact:1").add_to_contact
