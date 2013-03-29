require 'aliyun/oss'

config=YAML.load(File.open("#{Rails.root}/config/userconfig.yaml"))

# load format
format_config=config['format']
$CSVSP=format_config[:csv_splitor] # csv splitor

#load path
path_config=config['path']
$DECSVP=path_config[:demand_csv_path] # demand csv file save path
$DETMP=path_config[:demand_tmp_path] # demand tmo file path, for download 
$DNLABELPDFP=path_config[:dn_pdf_label_path] # delivery note and delivery package label pdf file path
$PRINTERTEMPLATEPATH=path_config[:printer_template_path] # printer template path
# load title
title_config=config['title']
$DECSVT=title_config[:demand_csv_title]
$DECSVTasC=title_config[:demand_csv_title_as_client]
$DECSVTasS=title_config[:demand_csv_title_as_supplier]
#load page
page_config=config['page']
$DEPSIZE=page_config[:demand_page_size].to_i # demand page size

# load resque
# resque_config=config['resque']
# Resque.redis=Redis.new(:host=>resque_config[:resquehost],:port=>resque_config[:resqueport],:db=>resque_config[:resquedb])
# Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }

Dir["#{Rails.root}/app/tprinters/*.rb"].each { |file| require file }

Aliyun::OSS::Base.establish_connection!(
  :access_key_id     => 'VDXgx2g1F7gZe8SY', 
  :secret_access_key => 'cVJoHKSh377Al7il90VuQD7Fo1GiPG'
)

class AliBucket < Aliyun::OSS::OSSObject
  set_current_bucket_to 'scm-dn'
end

class AliDnPrintTemplateBuket<Aliyun::OSS::OSSObject
   set_current_bucket_to 'scm-printer-template'
end