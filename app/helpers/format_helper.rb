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
  
  def self.label_xaxis( sec )
    Time.at(sec).strftime('%m/%d/%Y %H:%M')
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
     return  "#{date.year.to_s}/#{date.month.to_s}/#{date.day.to_s}"
       elsif type=='W'
         return  "#{date.year.to_s}/#{date.cweek.to_s}"
     elsif type=='M'
       return  "#{date.year.to_s}/#{date.month.to_s}"
     elsif type=='Y'
       return  "#{date.year.to_s}"
     end
   end
   return nil
   end
   
   def self.demand_date_to_date date,type
    if date
       if type=='D'
          return  Time.parse(date)
       elsif type=='W'
           yw = date.split('/')
           date = Time.parse("#{yw.first}/1/1")+(60*60*24)*7*(yw.last.to_i-1)
           date -= (60*60*24)*date.wday  if date.wday>0
           date += (60*60*24)
          return  date
       elsif type=='M'
           return  Time.parse(date)
       elsif type=='Y'
          return  Time.parse("#{date}/1/1")
       end
   end
   return nil
   end

end