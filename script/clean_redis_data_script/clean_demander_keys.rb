class CleanDemanderKeys
  def self.clean 
    ["Demander:*","#{Rns::C}:*", "#{Rns::S}:*","#{Rns::RP}:*","#{Rns::Date}*","#{ Rns::Amount}*",
      "cId:*:spId:*:relpartId:*:type:*:date:*"].each do |p|
        $redis.keys(p).each do |k|
          puts "#{k}-#{$redis.del k}"
        end
      end
    
  end
end

CleanDemanderKeys.clean
