#encoding: utf-8

require 'base_class'

class FileData<CZ::BaseClass
  attr_accessor :type,:oriName,:size,:path,:pathName,:data,:extention,:uuidName
  def default
    {:uuidName=>UUID.generate}
  end
  def saveFile
    @extention=File.extname(@oriName).downcase
    @pathName=@uuidName+@extention if @pathName.nil?
    File.open(File.join(@path,@pathName),'wb') do |f|
      f.write(@data.read)
    end
  end
end