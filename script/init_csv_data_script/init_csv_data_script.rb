#encoding: utf-8
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

  def self.initStaff staffs
    if staffs.count>0
      staffs.each do |arg|
        if !s=Staff.find(:first,:conditions=>{:name=>arg[:staffNr],:orgId=>arg[:orgId],:organisation_id=>arg[:orgId]})
          puts "create staff: staffNr:#{arg[:staffNr]}  orgId:#{arg[:orgId]}"
          begin
          st=Staff.new(:staffNr => arg[:staffNr], :name=>arg[:name], :orgId=>arg[:orgId],:password => arg[:pass], :organisation_id=>arg[:orgId],
           :password_confirmation => arg[:conpass]).save!
          rescue Exception=>e
           puts e.message
          end
        end
      end
    end
  end

end

# add org
orgs=InitCSVDataScript.initOrgByFile 'org20121109-leoni-cz'
# add org rel
InitCSVDataScript.initCSByOrgFile orgs,'csrel20121109-leoni-cz'
# add part and build rel
InitCSVDataScript.initPartAndCSPartRel orgs[0],orgs[1],'part20121109-leoni-cz'

# init staff
staffs=[{:name=>'leoni',:staffNr=>'leoni',:pass=>'leoni',:conpass=>'leoni',:orgId=>orgs[0].id},
{:name=>'leonicz',:staffNr=>'leonicz',:pass=>'leonicz',:conpass=>'leonicz',:orgId=>orgs[1].id}]
InitCSVDataScript.initStaff staffs

# add org
orgs=[]
orgs<<Organisation.find_by_id(1)
orgs<<(InitCSVDataScript.initOrgByFile 'org20121203-leoni-nb')[0]
# add org rel
InitCSVDataScript.initCSByOrgFile orgs,'csrel20121203-leoni-nb'
# add part and build rel
InitCSVDataScript.initPartAndCSPartRel orgs[0],orgs[1],'part20121203-leoni-nb'

# init staff
staffs=[{:name=>'nbtp',:staffNr=>'nbtp',:pass=>'nbtp@',:conpass=>'nbtp@',:orgId=>orgs[1].id}]
InitCSVDataScript.initStaff staffs