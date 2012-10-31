class PartController<ApplicationController
  def searcher

  end
 
  # ws part search
  def search
    session[:userId]=2
    params[:q].gsub!(/'/,'')
puts '1---------------------------------------------------------------------------------------------------------------------' 
    @search = Redis::Search.complete("Part", params[:q],:conditions=>{:orgId=>1})
 
     @search.collect do |item|
       puts item
    end
   
    render :json=>(parts=[])
  end
end