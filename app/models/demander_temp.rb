#coding:utf-8
require 'base_class'

class DemanderTemp<CZ::BaseClass
  attr_accessor :clientId,:relpartId,:supplierId, :type,:amount,:oldamount,:date,:rate,
  :clientNr,:supplierNr,:cpartId,:cpartNr,:spartId,:spartNr,:filedate,:vali,:lineNo,:msg,:source
  def gen_md5_repeat_key
    Digest::MD5.hexdigest(@clientId.to_s+':'+@cpartNr+':'+@type+':'+(@date.nil? ? '' : @date)+':'+@supplierNr)
  end

  def amount t=nil
    return FormatHelper::get_number @amount,t
  end

  def oldamount t=nil
    return FormatHelper::get_number @oldamount,t
  end
end