#coding:utf-8
require 'enum/file_data_type'

class DemanderController<ApplicationController
  def upload_demands
    if request.get?
      else
      files=params[:files]
      begin
        dir='uploadfiles/demands/csv'
        hfiles=[]
        if files.count>0
          uuid=UUID.new
          files.each do |f|
            hf={:oriName=>f.original_filename,:pathName=>uuid.generate}
            dcsv=FileData.new({:data=>f,:type=>FileDataType::Demand,:path=>dir}.merge(hf))
            dcsv.save
            hfiles<<hf
          end
          # render :json=>{:flag=>true,:msg=>'ok'}
          # validate and show result
          
          
          #...........
        else
          render :json=>{:flag=>false,:msg=>'no files'}
        end
      rescue=>e
         render :json=>{:flag=>false,:msg=>e}
      end
    end
  end
end