(926..1000).each do |item|
  if pr = PartRel.find_by_id( item )
    pr.destroy
  end
end
