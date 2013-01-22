#coding:utf-8
require 'base_class'

class DemanderTemp<CZ::BaseClass
  attr_accessor :clientId,:relpartId,:supplierId, :type,:amount,:oldamount,:date,:rate,
  :clientNr,:supplierNr,:cpartId,:cpartNr,:spartId,:spartNr,:filedate,:vali,:lineNo,:msg,:source

  def gen_md5_repeat_key
    Digest::MD5.hexdigest(@clientId.to_s+':'+@cpartNr+':'+@type+':'+(@date.nil? ? '' : @date)+':'+@supplierNr)
  end
 
end