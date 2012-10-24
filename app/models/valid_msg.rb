class ValidMsg<BaseMsg
  attr_accessor :result,:content,:content_key,:fields
  
  @@valids={:pnrNotEx=>'part nr does not exist',
            :spNrNotEx=>'supplier nr not exsit',
            :partNotFitOrgP=>'part nr not fit org part',
            :partMutiFitOrgP=>'part nr fit muti org parts',
            :fcDateErr=>'forecast date format error or less than now',
            :fcTypeNotEx=>'forecast type not exist',
            :pAmountIsIntOrLessZero=>'part amount is not int or less than 0',
            :fcRepeat=>'forcast is repeat in this time',
            :pOneToMuti=>'part is one to muti rela'}
            
  def initialize
    @result=true
    @content_key=[]
  end
  
  def countents
    if @content_key.count>0
      @content=[]
      @content_key.each do |key|
        @content<<@@valids[key]
      end
    end
  end
  
  def add_content msg
      @content=[] if !@content
      @content<<msg
  end
end