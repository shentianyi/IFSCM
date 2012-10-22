#coding:utf-8
require 'csv'
require 'digest/md5'
module DemanderHelper
  # alias :PartNr  :
  def generate_by_csv(files)
      begin
        if files
          files.each do |f|
            CSV.foreach(File.join(f[:path],f[:pathName]),:headers=>true,:col_sep=>$CSVSP) do |row|
            demand= Demander.new
            end
          end
        end
      rescue=>e
        puts e.to_s
      end
    end
    
    
end
