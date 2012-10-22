class FileData

  attr_accessor :type,:oriName,:size,:path,:pathName,:data,:extention,:uuidName
  
  def initialize args
    @data=args[:data]
    @type=args[:type]
    @oriName=args[:oriName]
    @path=args[:path]
    @uuidName=args[:uuidName]
    @extention=File.extname(@oriName).downcase
    @pathName=@uuidName+@extention
  end
  
  def save
   File.open(File.join(@path,@pathName),'wb') do |f|
      f.write(@data.read)
    end
  end
end