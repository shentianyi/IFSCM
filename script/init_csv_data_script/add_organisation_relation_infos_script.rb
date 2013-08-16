#encoding: utf-8
require 'enum/org_rel_contact_type'
require 'enum/org_rel_printer_type'
require 'org_rel_info'

Organisation.all.each_with_index do |org,i|
  puts "#{i+1}.#{org.name}"
  printer=OrgPrinter.new(:key_id=>org.id,:template=>"Leoni_Nbtp_PackCheckA4Template.tff",
  :moduleName=>"NbtpPreDnStoreCheckList",:type=> OrgRelPrinterType::DNPrecheckPrinter)
  printer.add_to_printer
  printer.add_to_dpriter
  printer.save
end