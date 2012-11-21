#coding:utf-8

module PartRelMetaHelper
  def  self.redis_search_by_conditions q,options=nil
    prms=[]
    puts "q:#{q}"
    result,total= Redis::Search.complete("PartRelMeta",q,options)
    result.collect do |r|
      prms<<PartRelMeta.new(r)
    end
    return prms,total if options[:startIndex]
    return prms
  end
end