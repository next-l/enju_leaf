# Put all your default configatron settings here.

# Example:
#   configatron.emails.welcome.subject = 'Welcome!'
#   configatron.emails.sales_reciept.subject = 'Thanks for your order'
# 
#   configatron.file.storage = :s3

configatron.enju.web_hostname = 'localhost'
configatron.enju.web_port_number = 3000

# パトロンの名前を入力する際、姓を先に表示する
configatron.family_name_first = true

configatron.max_number_of_results = 500
configatron.write_search_log_to_file = true
configatron.csv_charset_conversion = true

configatron.google_maps.api_key = 'REPLACE_WITH_YOUR_GOOGLE_MAPS_API_KEY'
configatron.google_maps.application_id = configatron.google_maps.api_key

configatron.amazon.access_key = 'REPLACE_WITH_YOUR_AMAZON_KEY'
configatron.amazon.secret_access_key = 'REPLACE_WITH_YOUR_AMAZON_SECRET_KEY'

# Choose a locale from 'ca', 'de', 'fr', 'jp', 'uk', 'us'
#AMAZON_AWS_HOSTNAME = 'ecs.amazonaws.com'
configatron.amazon.aws_hostname = 'ecs.amazonaws.jp'
configatron.amazon.hostname = 'www.amazon.co.jp'

configatron.calil.app_key = 'REPLACE_WITH_YOUR_CALIL_APP_KEY'
configatron.calil.secret_key = 'REPLACE_WITH_YOUR_CALIL_SECRET_KEY'
