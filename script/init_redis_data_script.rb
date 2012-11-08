# 1. init part data
require 'redis'
require 'enum/part_rel_type'

class InitData
  # init demand type
  def self.initDemandType
    $redis.del DemandType.gen_set_key
    ['D','W','M','Y'].each do |t|
      $redis.sadd DemandType.gen_set_key,t
    end
  end

  def self.initStaff
    Staff.create(  :staffNr => 'leoni', :name=>'leoni', :orgId=>1,:password => 'leoni',  :password_confirmation => 'leoni')
    Staff.create(  :staffNr => 'vw', :name=>'vw', :orgId=>2,:password => 'vw',  :password_confirmation => 'vw')
    Staff.create(  :staffNr => 'delpi', :name=>'delpi', :orgId=>3,:password => 'delpi',  :password_confirmation => 'delpi')
  end

  # init orgnisation
  def self.initOrg
    # add Leoni
    orgs=[]
    leoni=Organisation.new(:key=>Organisation.get_key(Organisation.gen_id),:name=>'Leoni', :description=>'A great company in car-wire field', :address=>'shang hai', :tel=>'012-00000001', :website=>'www.leoni.com')
    leoni.save
    Staff.find_by_staffNr('leoni').update_attributes(:orgId=>leoni.id)
    orgs<<leoni

    vw=Organisation.new(:key=>Organisation.get_key(Organisation.gen_id),:name=>'VW', :description=>'oh, just a car', :address=>'may be shanghai', :tel=>'012-00000002', :website=>'www.vw.com')
    vw.save
    Staff.find_by_staffNr('vw').update_attributes(:orgId=>vw.id)
    orgs<<vw

    delpi=Organisation.new(:key=>Organisation.get_key(Organisation.gen_id),:name=>'Delpi', :description=>'we donot like Leoni, we are enemy', :address=>'beside Leoni', :tel=>'012-00000003', :website=>'www.killleoni.com')
    delpi.save
    Staff.find_by_staffNr('delpi').update_attributes(:orgId=>delpi.id)
    orgs<<delpi

    leoni.add_supplier(vw.id,'VW-LEONI')
    leoni.add_supplier(delpi.id,'DELPI-LEONI')

    vw.add_client(leoni.id,'LEONI-VW')
    delpi.add_client(leoni.id,'LEONI-DELPI')

    initPart orgs
  end

  # init demand Part
  def self.initPart orgs=nil
    if orgs
      leoni=orgs[0]
      vw=orgs[1]
      delpi=orgs[2]
      # build leoni and vw
      for j in 1...11
        # 1. add part
        lp=Part.new(:key=>Part.gen_key,:orgId=>leoni.id,:partNr=>leoni.name+'Part000'+j.to_s)
        lp.save
        vp=Part.new(:key=>Part.gen_key,:orgId=>vw.id,:partNr=>vw.name+'Part000'+j.to_s)
        vp.save
        # 2. add part to org
        lp.add_to_org leoni.id
        vp.add_to_org vw.id

        PartRel.generate_cs_part_relation lp,vp

      end

      # build leoni and delpi
      for j in 11...21
        # 1. add part
        lp=Part.new(:key=>Part.gen_key,:orgId=>leoni.id,:partNr=>leoni.name+'Part000'+j.to_s)
        lp.save
        dp=Part.new(:key=>Part.gen_key,:orgId=>delpi.id,:partNr=>delpi.name+'Part000'+j.to_s)
        dp.save
        # 2. add part to org
        lp.add_to_org leoni.id
        dp.add_to_org delpi.id

        PartRel.generate_cs_part_relation lp,dp
      end

    end
  end

# init Part
end

$redis.flushall

InitData.initStaff
InitData.initDemandType
InitData.initOrg
# InitData.initPart
