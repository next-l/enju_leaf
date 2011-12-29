# -*- encoding: utf-8 -*-
# Put all your default configatron settings here.

# Example:
#   configatron.emails.welcome.subject = 'Welcome!'
#   configatron.emails.sales_reciept.subject = 'Thanks for your order'
# 
#   configatron.file.storage = :s3

configatron.enju.web_hostname = 'localhost'
configatron.enju.web_port_number = 3000

# 現在日付の表示 0:非表示 1:西暦 2:和暦
configatron.header.disp_date = 2

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

# 予約票の出力
configatron.reserve_print.filename = "reserve.pdf"
# 予約リスト(全体)の出力
configatron.reservelist_all_print.filename = "reservelist_all.pdf"
# 予約リスト(個人)の出力
configatron.reservelist_user_print.filename = "reservelist_user.pdf"
# 取置済み資料の出力
configatron.retained_manifestations_print.filename = "retained_manifestations.pdf"
# 予約表に利用者の年齢を表示するかどうか
configatron.reserve_print.old = true

# 連絡不可者の出力
configatron.unablelist_print.filename = "unablelist.pdf"

# 貸出状況の帳票ファイル名
configatron.checkoutlist_report.filename = "checkoutlist.pdf"

# 利用統計の帳票ファイル名
configatron.statistic_report.monthly = "monthly_report.pdf"
configatron.statistic_report.daily = "daily_report.pdf"
configatron.statistic_report.timezone = "timezone_report.pdf"
configatron.statistic_report.day = "day_report.pdf"
configatron.statistic_report.age = "age_report.pdf"
configatron.statistic_report.items = "items_report.pdf"
configatron.statistic_report.inout_items = "inout_items_report.pdf"
configatron.statistic_report.loans = "loans_report.pdf"
# 時間別統計の設定
configatron.statistic_report.open = 8
configatron.statistic_report.hours = 14 

# 資料の詳細画面に過去の貸出回数を表示
configatron.manifestation.display_checkouts_count = true
configatron.manifestation.display_reserves_count = true
configatron.manifestation.display_last_checkout_datetime = true

# 利用者一覧の色別表示
configatron.user.locked.background = "aqua"
configatron.user.unable.background = "yellow"

# 音
configatron.sounds.basedir = "sounds/"
#configatron.sounds.errors.a = "chimeA08.ogg"
#configatron.sounds.errors.c = "churchA08.ogg"
#configatron.sounds.errors.d = "missA11.ogg"
configatron.sounds.errors.item.this_item_is_reserved = "missA11.ogg"
configatron.sounds.errors.checkin.not_checkin = "chimeA08.ogg"
configatron.sounds.errors.checkin.already_checked_in = "missA11.ogg"
configatron.sounds.errors.checkin.overdue_item = "missA11.ogg"
configatron.sounds.errors.checkin.not_available_for_checkin = "churchA08.ogg"
configatron.sounds.errors.checkin.other_library_item = "chimeA08.ogg"
configatron.sounds.errors.checked_item.already_checked_out = "missA11.ogg"
configatron.sounds.errors.checked_item.not_available_for_checkout = "churchA08.ogg"
configatron.sounds.errors.checked_item.this_group_cannot_checkout = "churchA08.ogg"
configatron.sounds.errors.checked_item.in_transcation = "chimeA08.ogg"
configatron.sounds.errors.checked_item.reserved_item_included = "chimeA08.ogg"

# refs 1849 trueの場合=>一般利用者において、在架資料は、図書館利用時に借りることができる。
# 予約対象は貸出中の図書のみ
configatron.reserve.not_reserve_on_loan = true
