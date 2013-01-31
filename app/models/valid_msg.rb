#encoding: utf-8
require 'base_class'

class ValidMsg<BaseMsg
  attr_accessor :result,:content_key,:fields,:content
  
  @@valids={
            # for forcast 
            :pnrNotEx=>'零件号不存在',
            :spNrNotEx=>'供应商号不存在',
            :partNotFitOrgP=>'零件非此供应商生产',
            :partMutiFitOrgP=>'零件对应多个供应商零件',
            :fcDateErr=>'日期小于今日或格式错误',
            :fcTypeNotEx=>'预测类型不存在',
            :amountIsNotPositiveFloat=>'数量应大于零',
            :fcRepeat=>'预测重复',
            # for send delivery
            :partRelMetaNotEx=>'供应商-客户零件关系未建立',
            :packAmountIsNotInt=>'包装箱数应为正整数',
            :perPackAmountIsNotFloat=>'单位包装量应为大于零',
            :notSameClient=>'运单项需为同一客户'
            }
            
  def contents
    self.content=[] if !self.content
    if self.content_key.count>0
      self.content_key.each do |key|
       self.content<<@@valids[key]
      end
    end
    return self.content
  end
  
  def add_content msg
      self.content=[] if !self.content
      self.content<<msg
  end
end