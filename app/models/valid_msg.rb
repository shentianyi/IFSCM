class ValidMsg<BaseMsg
  attr_accessor :result,:content,:content_key
  
  @@valids={:pnrNotEx=>'part nr does not exist',
            :spNrNotEx=>'supplier nr not exsit',
            :partNotFitSp=>'part nr not fit supplier',
            :fcDateErr=>'forecast date format error or less than now',
            :fcTypeNotEx=>'forecast type not exist',
            :pAmountLessZero=>'part amount is less than 0',
            :fcRepeat=>'forcast is repeat in this time',
            :pOneToMuti=>'part is one to muti rela'}
            
  def initialize
    @result=true
    @content_key=[]
  end

end