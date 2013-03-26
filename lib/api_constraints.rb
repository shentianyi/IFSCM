class ApiConstraints
  
  def matches?(req)
    req.headers['Accept'].include?("application/ifscm.api}") 
  end
end
