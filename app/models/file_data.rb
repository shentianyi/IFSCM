class FileData

  attr_accessor :type,:oriName,:size,:path,:pathName,:data,:extention,:uuidName
  
  def initialize args={}
    if args.count>0
      args.each do |k,v|
        instance_variable_set "@#{k}",v
      end
      @extention=File.extname(@oriName).downcase
      @pathName=@uuidName+@extention
    end
  end

  def save
    File.open(File.join(@path,@pathName),'wb') do |f|
      f.write(@data.read)
    end
  end
end