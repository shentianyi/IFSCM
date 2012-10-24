require 'base_class'

class ValidMsg<BaseMsg
  attr_accessor :result,:content_key,:fields,:content
  
  @@valids={:pnrNotEx=>'part nr does not exist',
            :spNrNotEx=>'supplier nr not exsit',
            :partNotFitOrgP=>'part nr not fit org part',
            :partMutiFitOrgP=>'part nr fit muti org parts',
            :fcDateErr=>'forecast date format error or less than now',
            :fcTypeNotEx=>'forecast type not exist',
            :pAmountIsIntOrLessZero=>'part amount is not int or less than 0',
            :fcRepeat=>'forcast is repeat in this time',
            :pOneToMuti=>'part is one to muti rela'}
            
  def countents
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