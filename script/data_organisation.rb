Staff.create(  :staffNr => 'admin',
                          :name=>'admin',
                          :orgId=>1002,
                          :password => 'admin',
                          :password_confirmation => 'admin')


$redis.flushall

org1 = Organisation.new( :key=>Organisation.get_key( 1001 ), 
                                      :name=>"彩卓",
                                      :address=>"North Shannxi Road",
                                      :tel=>"021-345566",
                                      :website=>"www.cz.cn" )
org1.save
                                      
org2 = Organisation.new( :key=>Organisation.get_key( 1002 ), 
                                      :name=>"莱尼",
                                      :address=>"Anting Road",
                                      :tel=>"021-399233",
                                      :website=>"www.leoni.de" )
org2.save

org3 = Organisation.new( :key=>Organisation.get_key( 1003 ), 
                                      :name=>"联想",
                                      :address=>"Zhangjiang Road",
                                      :tel=>"021-389222",
                                      :website=>"www.lenovo.com" )
org3.save

org4 = Organisation.new( :key=>Organisation.get_key( 1004 ), 
                                      :name=>"三星",
                                      :address=>"Nanjing Road",
                                      :tel=>"021-333444",
                                      :website=>"www.sumsung.com" )
org4.save

org5 = Organisation.new( :key=>Organisation.get_key( 1005 ), 
                                      :name=>"美国电话电报",
                                      :address=>"Huaihai Road",
                                      :tel=>"021-445566",
                                      :website=>"www.att.com" )
org5.save
                                      
#########################################################                            
org1.add_supplier( org2.id, 'Leoni' )
OrgRel.new( cs_key: org1.s_key, orgrelNr: 'Leoni' ).save_index

org1.add_supplier( org3.id, 'Lenovo' )
OrgRel.new( cs_key: org1.s_key, orgrelNr: 'Lenovo' ).save_index

org1.add_supplier( org4.id, 'SUMSUNG' )
OrgRel.new( cs_key: org1.s_key, orgrelNr: 'SUMSUNG' ).save_index

org1.add_supplier( org5.id, 'AT&T' )
OrgRel.new( cs_key: org1.s_key, orgrelNr: 'AT&T' ).save_index

org2.add_client( org1.id, 'CZ' )
OrgRel.new( cs_key: org2.c_key, orgrelNr: 'CZ' ).save_index

org2.add_client( org3.id, 'Lenovo' )
OrgRel.new( cs_key: org2.c_key, orgrelNr: 'Lenovo' ).save_index

org2.add_client( org4.id, 'SUMSUNG' )
OrgRel.new( cs_key: org2.c_key, orgrelNr: 'SUMSUNG' ).save_index

org2.add_client( org5.id, 'AT&T' )
OrgRel.new( cs_key: org2.c_key, orgrelNr: 'AT&T' ).save_index
#########################################################

demand = Demander.new( :key=>Demander.gen_key,
                                                      :clientId=>1001,
                                                      :supplierId=>1002,
                                                      :relpartId=>"2342342",
                                                      :date=>110001,
                                                      :amount=>1000,
                                                      :type=>'W' )
print "Demander:  "+demand.key.ljust(25)
puts demand.save
demand.save_to_send

demand = Demander.new( :key=>Demander.gen_key,
                                                      :clientId=>1001,
                                                      :supplierId=>1002,
                                                      :relpartId=>"23423421",
                                                      :date=>110001,
                                                      :amount=>1000,
                                                      :type=>'D' )
print "Demander:  "+demand.key.ljust(25)
puts demand.save
demand.save_to_send

demand = Demander.new( :key=>Demander.gen_key,
                                                      :clientId=>1001,
                                                      :supplierId=>1002,
                                                      :relpartId=>"23423422",
                                                      :date=>110001,
                                                      :amount=>1000,
                                                      :type=>'D' )
print "Demander:  "+demand.key.ljust(25)
puts demand.save
demand.save_to_send

demand = Demander.new( :key=>Demander.gen_key,
                                                      :clientId=>1001,
                                                      :supplierId=>1002,
                                                      :relpartId=>"23423423",
                                                      :date=>110001,
                                                      :amount=>1000,
                                                      :type=>'D' )
print "Demander:  "+demand.key.ljust(25)
puts demand.save
demand.save_to_send

demand = Demander.new( :key=>Demander.gen_key,
                                                      :clientId=>1001,
                                                      :supplierId=>1002,
                                                      :relpartId=>"23423424",
                                                      :date=>110001,
                                                      :amount=>1000,
                                                      :type=>'D' )
print "Demander:  "+demand.key.ljust(25)
puts demand.save
demand.save_to_send

demand = Demander.new( :key=>Demander.gen_key,
                                                      :clientId=>1003,
                                                      :supplierId=>1002,
                                                      :relpartId=>"2342342",
                                                      :date=>110001,
                                                      :amount=>1000,
                                                      :type=>'W' )
print "Demander:  "+demand.key.ljust(25)
puts demand.save
demand.save_to_send

demand = Demander.new( :key=>Demander.gen_key,
                                                      :clientId=>1003,
                                                      :supplierId=>1002,
                                                      :relpartId=>"23423421",
                                                      :date=>110001,
                                                      :amount=>1000,
                                                      :type=>'D' )
print "Demander:  "+demand.key.ljust(25)
puts demand.save
demand.save_to_send

demand = Demander.new( :key=>Demander.gen_key,
                                                      :clientId=>1003,
                                                      :supplierId=>1002,
                                                      :relpartId=>"23423422",
                                                      :date=>110001,
                                                      :amount=>1000,
                                                      :type=>'D' )
print "Demander:  "+demand.key.ljust(25)
puts demand.save
demand.save_to_send

demand = Demander.new( :key=>Demander.gen_key,
                                                      :clientId=>1003,
                                                      :supplierId=>1002,
                                                      :relpartId=>"23423423",
                                                      :date=>110001,
                                                      :amount=>1000,
                                                      :type=>'D' )
print "Demander:  "+demand.key.ljust(25)
puts demand.save
demand.save_to_send

demand = Demander.new( :key=>Demander.gen_key,
                                                      :clientId=>1003,
                                                      :supplierId=>1002,
                                                      :relpartId=>"23423424",
                                                      :date=>110001,
                                                      :amount=>1000,
                                                      :type=>'D' )
print "Demander:  "+demand.key.ljust(25)
puts demand.save
demand.save_to_send

demand = Demander.new( :key=>Demander.gen_key,
                                                      :clientId=>1002,
                                                      :supplierId=>1003,
                                                      :relpartId=>"2343342",
                                                      :date=>110002,
                                                      :amount=>2000,
                                                      :type=>'W' )
print "Demander:  "+demand.key.ljust(25)
puts demand.save
demand.save_to_send

demand = Demander.new( :key=>Demander.gen_key,
                                                      :clientId=>1003,
                                                      :supplierId=>1004,
                                                      :relpartId=>"2242342",
                                                      :date=>110003,
                                                      :amount=>1000,
                                                      :type=>'M' )
print "Demander:  "+demand.key.ljust(25)
puts demand.save
demand.save_to_send

demand = Demander.new( :key=>Demander.gen_key,
                                                      :clientId=>1004,
                                                      :supplierId=>1005,
                                                      :relpartId=>"234",
                                                      :date=>110004,
                                                      :amount=>500,
                                                      :type=>'D' )
print "Demander:  "+demand.key.ljust(25)
puts demand.save
demand.save_to_send