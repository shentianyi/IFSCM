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
    def self.generate_dn_pdf(template,dataset,dnKey)
      result={:result=>false}
       begin
       client = Savon.client do |wsdl,http|
       wsdl.document=@@wsdlPath
       end
    res = client.request :generate_dn_pdf do |soap|
      soap.input = ["GenerateDnPdf", {xmlns: "http://tempuri.org/"}]
      soap.body={
        :template=>template,
        :dataJson=>dataset,
        :dnKey=>dnKey
      }  
    end 
      if res.success?
        resResult=res.to_hash[:generate_dn_pdf_response][:generate_dn_pdf_result]
        result[:result]=resResult[:result]
        result[:content]=resResult[:content]
      end
      rescue => e
        result[:content]=e.message.to_s
      end
      return result
    end
  end
end