class String
  def to_num
    return self.to_f if self.include? '.'
    self.to_i
  end
end