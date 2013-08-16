#coding:utf-8
require 'savon'
class Wcfer
  module PdfPrinter
    HTTPI.log = false  
     Savon.configure do |config|
      config.soap_version = 1
      config.env_namespace = :s
      config.log = false
      config.logger=Rails.logger
    end 
    @@wsdlPath= File.expand_path("../MonoScmPrinterServicewsdl.xml", __FILE__)
    
    #ws
    # [功能：] 生成运单标签 pdf
    # 参数：
    # - json : dn
    # 返回值：
    # - bool,string : 生成结果，文件名 - hash 
    def self.generate_dn_pdf(template,dataset)
        msg=ReturnMsg.new
       begin
         if dataset.length>0
       client = Savon.client do |wsdl,http|
       wsdl.document=@@wsdlPath
       end
    res = client.request :generate_dn_pdf do |soap|
      soap.input = ["GenerateDnPdf", {xmlns: "http://tempuri.org/"}]
      soap.body={
        :template=>template,
        :dataJson=>dataset.to_json,
        :dnKey=>nil
      }  
    end 
      if res.success?
        resResult=res.to_hash[:generate_dn_pdf_response][:generate_dn_pdf_result]
        msg.result=resResult[:result]
        msg.content =resResult[:content]
      end
      else
         msg.content ="不存在需要打印条目"
      end
      rescue => e
         msg.content =e.message.to_s
      end
      return msg
    end
  end
end