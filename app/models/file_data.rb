class FileData
  attr_accessor :type,:oriName,:size,:path,:pathName,:data,:extention
  
  def initialize args
    @data=args[:data]
    @type=args[:type]
    @oriName=args[:oriName]
    @path=args[:path]
    @pathName=args[:pathName]
  end
  
  def save
    @extention=File.extname(@oriName).downcase
    File.open(File.join(@path,@pathName+@extention),'wb') do |f|
      f.write(@data.read)
    end
  end
end