format_config=YAML.load(File.open("#{Rails.root}/config/format.yaml"))['format']
$CSVSP=format_config[:csv_splitor] # csv splitor

