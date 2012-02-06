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

# フォームに入力済みの状態で、ファンクションキーによる画面遷移を行おうとするとアラート画面を表示
configatron.disp_alert_when_move_page_with_function = "true"

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

# 検索結果一覧の出力ボタンを表示するか(true => 全てのユーザーに対し表示, false => ライブラリアン権限以上ならば表示)
configatron.manifestations.users_show_output_button = true
# 検索結果一覧の出力
configatron.search_report_pdf.filename = "search_manifestations.pdf"
configatron.search_report_csv.filename = "search_manifestations.csv"

# 資料確認票のファイル名
configatron.manifestation_print.filename = "manifestation.pdf"

# 貸出票の出力
configatron.checkouts_print.filename = "checkouts.pdf"
configatron.checkouts_print.message = "本は大事に扱いましょう。期限はきちんと守りましょう。インターネットで延長ができます。"
# 貸出リスト(pdf)の出力
configatron.checkoutlist_print_pdf.filename = "checkoutlist.pdf"
# 貸出リスト(csv)の出力
configatron.checkoutlist_print_csv.filename = "checkoutlist.csv"
# 貸出リストに利用者の年齢を表示するかどうか
configatron.checkout_print.old = true

# 予約票の出力
configatron.reserve_print.filename = "reserve.pdf"
# 予約リスト(個人)の出力
configatron.reservelist_user_print.filename = "reservelist_user.pdf"
# 予約リスト(全体)の出力(PDF)
configatron.reservelist_all_print_pdf.filename = "reservelist_all.pdf"
# 予約リスト(全体)の出力(CSV)
configatron.reservelist_all_print_csv.filename = "reservelist_all.csv"
# 取置済み資料の出力
configatron.retained_manifestations_print.filename = "retained_manifestations.pdf"
# 予約表に利用者の年齢を表示するかどうか
configatron.reserve_print.old = true

# 利用者リストの出力(PDF)
configatron.userlist_pdf_print.filename = "userlist.pdf"
# 利用者リス知の出力(TSV)
configatron.userlist_tsv_print.filename = "userlist.csv"
# 連絡不可者の出力
configatron.unablelist_print.filename = "unablelist.pdf"
# 家族リストの出力(PDF)
configatron.familylist_pdf_print.filename = "familylist.pdf"
# 家族リス知の出力(TSV)
configatron.familylist_tsv_print.filename = "familylist.csv"

# 督促はがきのファイル名
configatron.reminder_postal_card_print.filename = "reminder_postal_card.pdf"
# 督促はがきの図書館メッセージ（最大全角242文字）
configatron.reminder_postal_card_message = "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789"
# 督促書のファイル名
configatron.reminder_letter_print.filename = "reminder_letter.pdf"
# 督促書の図書館メッセージ
configatron.reminder_letter_message = "図書館からお借りになったなった本や視聴覚資料などを、返す日が過ぎております。\n速やかにお返しください。\n\n・お返しになった後、行き違いにこの手紙が届きましたらご容赦ください。\n・図書館が閉まっているときは、入り口脇のブックポストをご利用ください。\n・視聴覚資料に限りましてはブックポストへの返却はご遠慮いただき、直接カウンターにお返しください。\n・資料を、郵送や宅配便でお返しいただく場合は、壊れないようご配慮の上お送りください。\n・ご不明な点がありましたらお問い合わせください。"
# 督促情報表のファイル名
configatron.reminder_list_pdf_print.filename = "reminder_list.pdf"
# 督促情報表のファイル名
configatron.reminder_list_csv_print.filename = "reminder_list.csv"

# 貸出状況の帳票ファイル名
configatron.checkoutlist_report_pdf.filename = "checkoutlist.pdf"
configatron.checkoutlist_report_tsv.filename = "checkoutlist.tsv"

# 予約状況の帳票ファイル名
configatron.reservelist_report_pdf.filename = "reservelist.pdf"
configatron.reservelist_report_tsv.filename = "reservelist.tsv"

# 利用統計の帳票ファイル名
configatron.statistic_report.monthly = "monthly_report.pdf"
configatron.statistic_report.monthly_tsv = "monthly_report.tsv"
configatron.statistic_report.daily = "daily_report.pdf"
configatron.statistic_report.daily_tsv = "daily_report.tsv"
configatron.statistic_report.timezone = "timezone_report.pdf"
configatron.statistic_report.timezone_tsv = "timezone_report.tsv"
configatron.statistic_report.day = "day_report.pdf"
configatron.statistic_report.day_tsv = "day_report.tsv"
configatron.statistic_report.age = "age_report.pdf"
configatron.statistic_report.age_tsv = "age_report.tsv"
configatron.statistic_report.items = "items_report.pdf"
configatron.statistic_report.items_tsv = "items_report.tsv"
configatron.statistic_report.inout_items = "inout_items_report.pdf"
configatron.statistic_report.inout_items_tsv = "inout_items_report.tsv"
configatron.statistic_report.loans = "loans_report.pdf"
configatron.statistic_report.loans_tsv = "loans_report.tsv"
configatron.statistic_report.groups = "groups_report.pdf"
configatron.statistic_report.groups_tsv = "groups_report.tsv"
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
configatron.reserve.not_reserve_on_loan = false

# refs 2042 蔵書点検時、未返却資料を検出した場合は自動的に返却処理を行う
configatron.library_checks.auto_checkin = true

# refs 2553 ユーザ情報重複チェック機能
configatron.patron.check_duplicate_user = false

# refs 2552 クライアント接続パスフレーズ
configatron.clientkey = "1234567890123456"

# refs 2601 すべてのユーザに検索結果の一覧の取得が出来るようにする
configatron.manifestations.users_show_output_button = false

# refs 1989 trueの場合 => itemがひとつだけのmanifestationのitemを削除するとき、除籍してからのみ削除できる
configatron.items.confirm_destroy = true

# refs 1991 雑誌最新号の貸出禁止
configatron.checkouts.cannot_for_new_serial = true

# refs 2588 所蔵のない資料の予約
configatron.reserves.able_for_not_item = true
