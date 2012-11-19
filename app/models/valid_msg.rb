#coding:utf-8
require 'base_class'

class ValidMsg<BaseMsg
  attr_accessor :result,:content_key,:fields,:content
  
  @@valids={:pnrNotEx=>'零件号不存在',
            :spNrNotEx=>'供应商号不存在',
            :partNotFitOrgP=>'零件非此供应商生产',
            :partMutiFitOrgP=>'零件对应多个供应商零件',
            :fcDateErr=>'日期小于今日或格式错误',
            :fcTypeNotEx=>'预测类型不存在',
            :pAmountIsNotNumOrLessZero=>'数量应大于0',
            :fcRepeat=>'预测重复'}
            
  def contents
    @content=[] if !@content
    if @content_key.count>0
      @content_key.each do |key|
       @content<<@@valids[key]
      end
    end
    return @content
  end
  
  def add_content msg
      @content=[] if !@content
      @content<<msg
  end
end