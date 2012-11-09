module FormatHelper
   
  # parse string to date 
  # string like '0000/00/00' is valid
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

   # valid if the date string is less than today
   def self.str_less_today str
     date=str_to_date(str)
     if date
       return date<Date.today
     end
     return true
   end
   
   # valid if string is int and less than 0
   def self.str_is_notint_less_zero str
     if str.to_i.to_s==str
       return str.to_i<0
     end
     return true
   end
   
   # demand date by date string and type
   def self.demand_date_by_str_type date,type
    date=str_to_date(date)
    if date
     if type=='D'
     return  "#{date.year}/#{date.month}/#{date.day}"
       elsif type=='W'
         return  "#{date.year}/#{date.cweek}"
     elsif type=='M'
       return  "#{date.year}/#{date.month}"
     elsif type=='Y'
       return  "#{date.year}"
     end
   end
   return nil
   end

end