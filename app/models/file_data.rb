require 'base_class'

class FileData<CZ::BaseClass

  attr_accessor :type,:oriName,:size,:path,:pathName,:data,:extention,:uuidName

  def saveFile
    @extention=File.extname(@oriName).downcase
    @pathName=@uuidName+@extention
    File.open(File.join(@path,@pathName),'wb') do |f|
      f.write(@data.read)
    end
  end
end