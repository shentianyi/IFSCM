require 'enum/part_rel_type'

class InitCSVDataScript
  
  include InitDataCsvHelper
  def self.initOrgByFile fileName
    InitDataCsvHelper::initOrgByCSV fileName
  end

  def self.initCSByOrgFile orgs,fileName
    InitDataCsvHelper::initCsRelByOrgFile orgs,fileName
  end

  def self.initPartAndCSPartRel c,s,fileName
    InitDataCsvHelper::initPartAndCsPartRel c,s,fileName
  end
  
  def self.initStaff c,s
    Staff.create(  :staffNr => 'leoni', :name=>'leoni', :orgId=>c.id,:password => 'leoni',  :password_confirmation => 'leoni')
    Staff.create(  :staffNr => 'leonicz', :name=>'leonicz', :orgId=>s.id,:password => 'leonicz',  :password_confirmation => 'leonicz')
  end

  
end
# add org
orgs=InitCSVDataScript.initOrgByFile 'org20121109'
# add org rel
InitCSVDataScript.initCSByOrgFile orgs,'csrel20121109'
# add part and build rel
InitCSVDataScript.initPartAndCSPartRel orgs[0],orgs[1],'part20121109'

# init staff
InitCSVDataScript.initStaff orgs[0],orgs[1]