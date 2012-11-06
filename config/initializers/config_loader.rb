require "resque/server"
 
config=YAML.load(File.open("#{Rails.root}/config/userconfig.yaml"))

# load format
format_config=config['format']
$CSVSP=format_config[:csv_splitor] # csv splitor

#load path
path_config=config['path']
$DECSVP=path_config[:demand_csv_path] # demand csv file save path
$DETMP=path_config[:demand_tmp_path] # demand tmo file path, for download 

# load title
title_config=config['title']
$DECSVT=title_config[:demand_csv_title]
#load page
page_config=config['page']
$DEPSIZE=page_config[:demand_page_size].to_i # demand page size

# load resque
resque_config=config['resque']
Resque.redis=Redis.new(:host=>resque_config[:resquehost],:port=>resque_config[:resqueport],:db=>resque_config[:resquedb])
Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }
