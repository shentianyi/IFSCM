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
  
  # init orgnisation
  def self.initOrg
    # add Leoni
    orgs=[]
    leoni=Organisation.new(:key=>Organisation.get_key(Organisation.gen_id),:name=>'Leoni', :description=>'A great company in car-wire field', :address=>'shang hai', :tel=>'012-00000001', :website=>'www.leoni.com')
    leoni.save
    orgs<<leoni
    
    vw=Organisation.new(:key=>Organisation.get_key(Organisation.gen_id),:name=>'VW', :description=>'oh, just a car', :address=>'may be shanghai', :tel=>'012-00000002', :website=>'www.vw.com')
    vw.save
    orgs<<vw
    
    delpi=Organisation.new(:key=>Organisation.get_key(Organisation.gen_id),:name=>'Delpi', :description=>'we donot like Leoni, we are enemy', :address=>'beside Leoni', :tel=>'012-00000003', :website=>'www.killleoni.com')
    delpi.save
    orgs<<delpi
    
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
         lp=Part.new(:key=>Part.gen_key,:orgId=>leoni.key,:partNr=>leoni.name+'Part000'+j.to_s)
         lp.save
         vp=Part.new(:key=>Part.gen_key,:orgId=>vw.key,:partNr=>vw.name+'Part000'+j.to_s)
         vp.save
         # 2. add part to org 
         lp.add_to_org leoni.key
         vp.add_to_org vw.key
         # 3. add part rel meta
         partRelMeta=PartRelMeta.new(:key=>PartRelMeta.gen_key,:cpartId=>lp.key,:spartId=>vp.key)
         partRelMeta.save
         # 4. add part Rel
         cpartRel=PartRel.new(:key=>PartRel.gen_key(leoni.key,vw.key,PartRelType::Client),:cId=>leoni.key,:sId=>vw.key,:type=>PartRelType::Client)
         cpartRel.add_partRel_meta(lp.key,partRelMeta.key)
         cpartRel.save
         
         spartRel=PartRel.new(:key=>PartRel.gen_key(leoni.key,vw.key,PartRelType::Supplier),:cId=>leoni.key,:sId=>vw.key,:type=>PartRelType::Supplier)
         spartRel.add_partRel_meta(vp.key,partRelMeta.key)
         spartRel.save

       end 
       
        # build leoni and delpi
       for j in 11...21
              # 1. add part
         lp=Part.new(:key=>Part.gen_key,:orgId=>leoni.key,:partNr=>leoni.name+'Part000'+j.to_s)
         lp.save
         dp=Part.new(:key=>Part.gen_key,:orgId=>delpi.key,:partNr=>delpi.name+'Part000'+j.to_s)
         dp.save
         # 2. add part to org 
         lp.add_to_org leoni.key
         dp.add_to_org delpi.key
         # 3. add part rel meta
         partRelMeta=PartRelMeta.new(:key=>PartRelMeta.gen_key,:cpartId=>lp.key,:spartId=>dp.key)
         partRelMeta.save
         # 4. add part Rel
         cpartRel=PartRel.new(:key=>PartRel.gen_key(leoni.key,delpi.key,PartRelType::Client),:cId=>leoni.key,:sId=>delpi.key,:type=>PartRelType::Client)
         cpartRel.add_partRel_meta(lp.key,partRelMeta.key)
         cpartRel.save
         
         spartRel=PartRel.new(:key=>PartRel.gen_key(leoni.key,delpi.key,PartRelType::Supplier),:cId=>leoni.key,:sId=>delpi.key,:type=>PartRelType::Supplier)
         spartRel.add_partRel_meta(dp.key,partRelMeta.key)
         spartRel.save
       end 
        
   end
  end
  
  # init Part
end
$redis.flushall
InitData.initDemandType
InitData.initOrg
# InitData.initPart
