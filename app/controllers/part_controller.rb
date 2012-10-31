class PartController<ApplicationController
  def searcher

  end
 
  # ws part search
  def search
    session[:userId]=1
    params[:q].gsub!(/'/,'')
    arr=[]
    @search = Redis::Search.complete("Part", params[:q],:conditions=>{:orgId=>session[:userId]})
    lines = @search.collect do |item|
      puts item
    end
    render :text => lines.join("\n")
  end
end