module DateHelper
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
end