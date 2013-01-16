#coding:utf-8
module TPrinter
  def self.print_dn_pdf dnKey,mname,template
    dataset = eval(mname.camelize).send :gen_data,dnKey
    return Wcfer::PdfPrinter.generate_dn_pdf(template,dataset.to_json,dnKey)
  end
end