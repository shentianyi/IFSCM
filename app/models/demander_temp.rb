class DemanderTemp<Demander
  attr_accessor :clientId,:clientNr,:supplierNr,:cpartId,:cpartNr,:spartId,:spartNr,:filedate,:vali,:lineNo,:uuid,:msg,:source

  def gen_md5_repeat_key
    Digest::MD5.hexdigest(@clientId.to_s+':'+@cpartNr+':'+@type+':'+(@date.nil?? '' : @date)+':'+@supplierNr)
  end
  
  
end