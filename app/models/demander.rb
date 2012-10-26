#coding:utf-8
require 'digest/md5'
require 'base_class'

class Demander<CZ::BaseClass
  attr_accessor :key,:clientId,:relpartId,:supplierId, :type,:amount,:date,:rate
  
  def self.gen_index
    $redis.incr 'demand:index:incr'
  end
   
  
  def self.get_key( id )
    Rns::De+":#{id}"
  end
   
  def self.search( hash )
      list = []
      resultKey = "resultKey"
      ###########################  client
      if client = union_params( hash[:client], Rns::C )
      list<<client
      end
      ###########################  supplier
      if supplier = union_params( hash[:supplier], Rns::S )
      list<<supplier
      end
      ###########################  part
      if relpart = union_params( hash[:rpartNr], Rns::RP )
      list<<relpart
      end
      ###########################  type
      if type = union_params( hash[:type], Rns::T )
      list<<type
      end
      ###########################  date
      list<<Rns::Date
      
      $redis.zinterstore( resultKey, list, :aggregate=>"MAX" )
      $redis.expire( resultKey, 30 )
      resultKey
      
  end
  
  def self.test( hash )
    hash[:sdi]
  end
  
  
private
  def self.union_params( param, column )
      if param.size>0 && param.is_a?(String)
          key = "#{column}:#{param}"
      elsif param.is_a?(Array)
          key = column
          param.each do |c|
            c.insert( 0, "#{column}:" )
          end
          $redis.zunionstore( key, param )
          key
      else
          return false
      end
  end
end