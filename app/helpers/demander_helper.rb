#coding:utf-8
require 'csv'
require 'digest/md5'

module DemanderHelper
  # alias :PartNr  :
  def generate_by_csv(files)
      begin
        if files
          files.each do |f|
            # csv header
            CSV.foreach(File.join(f[:path],f[:pathName]),:headers=>true,:col_sep=>$CSVSP) do |row|
             demand= Demander.new
             demand.partNr=row[0]
             demand.supplier=row[1]
             demand.filedate=row[2]
             demand.type=row[3]
             demand.amount=row[4]
             
             dmd5=Digest::MD5.hexdigest(demand.partNr+supplier)
            end
          end
        end
      rescue=>e
        puts e.to_s
      end
    end
    
    
end
