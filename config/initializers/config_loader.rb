config=YAML.load(File.open("#{Rails.root}/config/userconfig.yaml"))

format_config=config['format']
$CSVSP=format_config[:csv_splitor] # csv splitor

path_config=config['path']
$DECSVP=path_config[:demand_csv_path] # demand csv file save path

page_config=config['page']
$DEPSIZE=page_config[:demand_page_size].to_i # demand page size

