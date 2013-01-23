class String
  def to_num
    return self.to_f if self.include? '.'
    self.to_i
  end
end



class Rns
  
  C = "client"
  S = "supplier"
  Org = "organisation"
  
  De = "demand"
  T = "type"
  RP = "relpart"
  Date = "date"
  Amount = "amount"
  
  Kes = "kestrel"
  
  
end