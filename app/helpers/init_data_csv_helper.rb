#coding:utf-8
#encoding=UTF-8
require 'csv'

module InitDataCsvHelper
  @@path='initData/initOri'
  @@bakpath='initData/initBak'
  # ws : init org from csv
  def self.initOrgByCSV fileName
    orgs=[]
    CSV.foreach(File.join(@@path,fileName+'.csv'),:headers=>true,:col_sep=>$CSVSP) do |row|
      puts "----- init org : #{row["Name"]}----------------------------"
      org=Organisation.new(:key=>Organisation.get_key(Organisation.gen_id),:name=>row["Name"],:description=>row["Description"],
      :address=>row["Address"], :tel=>row["Tel"], :website=>row["Website"],:abbr=>row["Abbr"],:contact=>row["Contact"],:email=>row["Email"])
      org.save
      orgs<<org
    end
    #writeBak fileName,orgs
    return orgs
  end

  # init cs Rel
  def self.initCsRelByCSV fileName
    CSV.foreach(File.join(@@path,fileName+'.csv'),:headers=>true,:col_sep=>$CSVSP) do |row|
      puts "----- init Cs Rel : #{row["ClientKey"]}<-->#{row["SupplierKey"]}----------------------------"
      c=Organisation.find(row["ClientKey"])
      s=Organisation.find(row["SupplierKey"])
      c.add_supplier(s.id,row["SupplierNr"])
      s.add_client(c.id,row["ClientNr"])
    end
  end

  # init cs rel by orgs
  def self.initCsRelByOrgFile orgs,fileName
    i=0
    CSV.foreach(File.join(@@path,fileName+'.csv'),:headers=>true,:col_sep=>$CSVSP) do |row|
      orgs[i].add_supplier(orgs[i+1].id,row["SupplierNr"])
      orgs[i+1].add_client(orgs[i].id,row["ClientNr"])
      i+=2
    end
  end

  # init part and cs part rel
  def self.initPartAndCsPartRel c,s,fileName
    CSV.foreach(File.join(@@path,fileName+'.csv'),:headers=>true,:col_sep=>$CSVSP) do |row|
      puts "--------CPartNr:#{row["CpartNr"]}---SPartNr:#{row["SpartNr"]}--------------------"
      cp=sp=nil
      if !cp=Part.find_partKey_by_orgId_partNr(c.id,row["CpartNr"])
        cp=Part.new(:key=>Part.gen_key,:orgId=>c.id,:partNr=>row["CpartNr"])
        cp.save
       cp.add_to_org c.id
      end

      if !sp= Part.find_partKey_by_orgId_partNr(s.id,row["SpartNr"])
        sp=Part.new(:key=>Part.gen_key,:orgId=>s.id,:partNr=>row["SpartNr"])
       sp.save
       sp.add_to_org s.id
      end

      if !PartRel.get_single_part_cs_parts c.id,s.id,cp.key,PartRelType::Client
        PartRel.generate_cs_part_relation cp,sp,row["SaleNo"]||"",row["PurchaseNo"]||""
      end
    end
  end

  # write bak -- contain key
  def self.writeBak fileName,objs
    File.open(File.join(@@bakpath ,fileName+'--'+UUID.generate+'.csv'),'w+') do |f|
    # puts title
      if objs.count>0
        f.puts objs[0].instance_variables.collect! {|x| x.to_s.sub(/@/,'').capitalize}.join($CSVSP)
      end
      objs.each do |o|
        attrs=[]
        o.instance_variables.each do |attr|
          attrs<< o.instance_variable_get(attr)
        end
        f.puts attrs.join($CSVSP)
      end
    end
  end

end