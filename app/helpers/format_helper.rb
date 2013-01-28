#encoding: utf-8
module FormatHelper
  # parse string to date
  # string like '0000/00/00' is valid
  def self.str_to_date str
    return nil if str.nil?
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
    Time.at(sec).strftime('%m/%d/%Y')
  end

  # valid if the date string is less than today
  def self.str_less_today str
    date=str_to_date(str)
    if date
      return date<Date.today
    end
    return true
  end

  # vali if string is positive float
  def self.str_is_positive_float str
    return /^[\d]+(\.[\d]+){0,1}$/ ===str
  end

  # vali if string is positive integer
  def self.str_is_positive_integer str
    return (/^[1-9]\d*$/ ===str)
  end

  # demand date by date string and type
  def self.demand_date_by_str_type date,type
    date=str_to_date(date)
    if date
      if type=='D' or type=='T'
        return  "#{date.year}/#{date.month}/#{date.day}"
      elsif type=='W'
        return  "#{date.year}/#{date.cweek}"
      elsif type=='M'
        return  "#{date.year}/#{date.month}"
      elsif type=='Y'
        return  "#{date.year}"
      end
    end
    return ""
  end

  def self.demand_date_inside date,type
    if date
      if type=='D' or type=='T'
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
  
 def self.demand_date_outside date,type
    if date
      if type=='D' or type=='T'
        return  "#{date.year}/#{date.month}/#{date.day}"
      elsif type=='W'
        return  "#{date.year}/#{date.cweek}"
      elsif type=='M'
        return  "#{date.year}/#{date.month}"
      elsif type=='Y'
        return  "#{date.year}"
      end
    end
    return ""
  end

  # ws : get os name
  def self.get_os_name user_agent
    user_agent=user_agent.downcase
    [/windows/,/linux/].each do |o|
      if os=o.match(user_agent)
      return os[0]
      end
    end
  end

  # ws : csv encode
  def self.csv_write_encode user_agent

    user_agent=user_agent.downcase
    os=nil
    [/windows/,/linux/].each do |o|
      if s=o.match(user_agent)
      os=s[0]
      break
      end
    end

    case os
    when 'windows'
      return 'GB18030'
    when 'linux'
      return 'UTF-8'
    else
    return nil
    end
  end

  # ws
  def self.get_number num,t=nil
    return nil if num==''
    return num if !t.nil?
    if num.is_a?(String)
      return num.to_f if num.include?('.')
    return num.to_i
    end
    return num
  end

  def self.string_multiply n1,n2
    n1=n1.to_s if !n1.is_a?(String)
    n2=n2.to_s if !n2.is_a?(String)
    if n1.include?('.') or n2.include?('.')
      return (BigDecimal.new(n1)*BigDecimal.new(n2)).to_f
    else
    return n1.to_i*n2.to_i
    end
  end
  
  def self.string_to_int str
   return str.sub(/(\.0)$/,'')
  end
end