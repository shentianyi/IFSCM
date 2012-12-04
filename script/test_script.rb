p=Part.find_partKey_by_orgId_partNr(1,'12')
puts p
puts p.class

p=Part.find_partKey_by_orgId_partNr(1,"499110510")
puts p
puts p.class