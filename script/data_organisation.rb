Staff.create(  :staffNr => 'admin',
                          :name=>'管理员',
                          :orgId=>1002,
                          :password => 'admin',
                          :password_confirmation => 'admin')


$redis.flushall

org1 = Organisation.new( :key=>Organisation.get_key( 1001 ), 
                                      :name=>"彩卓",
                                      :address=>"North Shannxi Road", :tel=>"021-345566", :website=>"www.cz.cn" )
org1.save
                                      
org2 = Organisation.new( :key=>Organisation.get_key( 1002 ), 
                                      :name=>"莱尼",
                                      :address=>"Anting Road", :tel=>"021-399233", :website=>"www.leoni.de" )
org2.save

org3 = Organisation.new( :key=>Organisation.get_key( 1003 ), 
                                      :name=>"联想",
                                      :address=>"Zhangjiang Road", :tel=>"021-389222", :website=>"www.lenovo.com" )
org3.save

org4 = Organisation.new( :key=>Organisation.get_key( 1004 ), 
                                      :name=>"三星",
                                      :address=>"Nanjing Road", :tel=>"021-333444", :website=>"www.sumsung.com" )
org4.save

org5 = Organisation.new( :key=>Organisation.get_key( 1005 ), 
                                      :name=>"美国电话电报",
                                      :address=>"Huaihai Road", :tel=>"021-445566",  :website=>"www.att.com" )
org5.save
                                      
#########################################################                            
org1.add_supplier( org2.id, 'Leoni' )
org2.add_client( org1.id, 'CZ' )

org1.add_supplier( org3.id, 'Lenovo' )
org3.add_client( org1.id, 'CZ' )

org1.add_supplier( org4.id, 'SUMSUNG' )
org4.add_client( org1.id, 'CZ' )

org1.add_supplier( org5.id, 'AT&T' )
org5.add_client( org1.id, 'CZ' )


org2.add_client( org3.id, 'Lenovo' )
org3.add_supplier( org2.id, 'Leoni' )

org2.add_client( org4.id, 'SUMSUNG' )
org4.add_supplier( org2.id, 'Leoni' )

org2.add_client( org5.id, 'AT&T' )
org5.add_supplier( org2.id, 'Leoni' )
#########################################################
