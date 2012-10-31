class PartController<ApplicationController
  def searcher

  end
 
  # ws part search
  def search
    session[:userId]=2
    params[:q].gsub!(/'/,'')
    arr=[]
    @search = Redis::Search.complete("Part", params[:q],:conditions=>{:orgId=>session[:userId]})
    parts =[]
     @search.collect do |item|
       puts item
         parts<<Part.new(:key=>item['key'],:orgId=>item['orgId'],:partNr=>item['partNr'])
    end
    render :json=>parts
  end
end