# -*- encoding: utf-8 -*-
# Put all your default configatron settings here.

# Example:
#   configatron.emails.welcome.subject = 'Welcome!'
#   configatron.emails.sales_reciept.subject = 'Thanks for your order'
# 
#   configatron.file.storage = :s3

configatron.enju.web_hostname = 'localhost'
configatron.enju.web_port_number = 3000

# 現在時刻の表示
configatron.header.disp_date = true

# パトロンの名前を入力する際、姓を先に表示する
configatron.family_name_first = true

configatron.max_number_of_results = 500
configatron.write_search_log_to_file = true
configatron.csv_charset_conversion = true

# Choose a locale from 'ca', 'de', 'fr', 'jp', 'uk', 'us'
#AMAZON_AWS_HOSTNAME = 'ecs.amazonaws.com'
configatron.amazon.aws_hostname = 'ecs.amazonaws.jp'
configatron.amazon.hostname = 'www.amazon.co.jp'

# :google, :amazon
configatron.book_jacket.source = :google

# :mozshot, :simpleapi, :heartrails, :thumbalizr
configatron.screenshot.generator = :mozshot

# set disp column of checkins 
configatron.checkins.disp_title = true
configatron.checkins.disp_user = true

# set disp column of checked_items
configatron.checked_items.disp_title = true
configatron.checked_items.disp_user = true

# template file for import
configatron.resource_import_template = "templates/resource_import_template.zip"

# 無操作待機時間 (sec)
#configatron.no_operation_counter = 300
configatron.no_operation_counter = 0

# 貸出票の出力
configatron.checkouts_print.filename = "checkouts.pdf"
configatron.checkouts_print.message = "本は大事に扱いましょう。期限はきちんと守りましょう。インターネットで延長ができます。"

# 連絡不可者の出力
configatron.unablelist_print.filename = "unablelist.pdf"

# 利用統計の帳票ファイル名
configatron.statistic_report.monthly = "monthly_report.pdf"
configatron.statistic_report.daily = "daily_report.pdf"
configatron.statistic_report.timezone = "timezone_report.pdf"
configatron.statistic_report.day = "day_report.pdf"
# 時間別統計の設定
configatron.statistic_report.open = 9
configatron.statistic_report.hours = 12 
