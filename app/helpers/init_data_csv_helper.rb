#coding:utf-8
#encoding=UTF-8
require 'csv'

module InitDataCsvHelper
  @@path='initData/initOri'
  
  # ws : init org from csv
  def self.initOrgByCSV fileName
    orgs=[]
    CSV.foreach(File.join(@@path,fileName+'.csv'),:headers=>true,:col_sep=>$CSVSP) do |row|
      puts "----- init org : #{row["Name"]}----------------------------"
      org=Organisation.new(:name=>row["Name"],:description=>row["Description"],
      :address=>row["Address"], :tel=>row["Tel"], :website=>row["Website"],:abbr=>row["Abbr"],:contact=>row["Contact"],:email=>row["Email"])
      org.save
      orgs<<org
    end
    return orgs
  end

  # init cs rel by orgs
  def self.initCsRelByOrgFile orgs,fileName
    i=0
    CSV.foreach(File.join(@@path,fileName+'.csv'),:headers=>true,:col_sep=>$CSVSP) do |row|
      OrganisationRelation.create(:clientNr=>row["ClientNr"], :supplierNr=>row["SupplierNr"], :origin_supplier_id=>orgs[i+1].id, :origin_client_id=>orgs[i].id)
      i+=2
    end
  end

  # init part and cs part rel
  def self.initPartAndCsPartRel c,s,fileName
    orgRel = OrganisationRelation.where("origin_client_id = ? and origin_supplier_id = ? ", c.id, s.id).first
    
    CSV.foreach(File.join(@@path,fileName+'.csv'),:headers=>true,:col_sep=>$CSVSP) do |row|
      cp=sp=nil
      if !cp= Part.where("organisation_id = ? and partNr = ?", c.id, row["CpartNr"]).first
        cp=Part.new(:partNr=>row["CpartNr"])
        c.parts<<cp
      end
      if !sp= Part.where("organisation_id = ? and partNr = ?", s.id, row["SpartNr"]).first
        sp=Part.new(:partNr=>row["SpartNr"])
        s.parts<<sp
      end
      PartRel.create(:saleNo=>row["SaleNo"]||"", :purchaseNo=>row["PurchaseNo"]||"",
                                                          :client_part_id=>cp.id, :supplier_part_id=>sp.id, :organisation_relation_id=>orgRel.id)
    end
    
  end


end