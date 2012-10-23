module FormatHelper
  def self.str_to_date str
    str=str.match(/^\d{4}\/(0?[1-9]|1[0-2])\/(0?[1-9]|[1-2]\d|3[0-1])$/)
    if str
      begin
        ['%Y/%m/%d'].each do |f|
          if date=Date.strptime(str.to_s, f)
            return Date.strptime(str.to_s, f)
          end
        end
      rescue

      end
    end
    return nil
  end

   def self.str_less_today str
     date=str_to_date(str)
     if date
       return date<Date.today
     end
     return false
   end
   
   def sef.str_is_int_less_zero str
     if str.to_i.to_s==str
       return str.to_i>0
     end
     return false
   end
   
   def self.nwd_by_dateStr_type date,type
    date=str_to_date(str)
    if date
     if type=='D'
     return  "year:#{date.year.to_s} month:#{date.month.to_s}day:#{date.day.to_s}"
       elsif type=='W'
         return  "year:#{date.year.to_s} week#{date.cweek.to_s}"
     elsif type=='M'
       return  "year:#{date.year.to_s} month:#{date.month.to_s}"
     elsif type=='Y'
       return  "year:#{date.year.to_s}"
     end
   end
   return nil
   end
   
  
   
end