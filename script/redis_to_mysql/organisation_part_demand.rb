class OrgToM
  
  def self.coping
    $redis.keys("Organisation:*").each do |orgK|
      hash={}
      $redis.hgetall(orgK).each do |k,b|
        next if k=="key"
        hash[k]=b
      end
      Organisation.create(hash)
    end
  end
end