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

# フォームに入力済みの状態で、ファンクションキーによる画面遷移を行おうとするとアラート面を表示
configatron.disp_alert_when_move_page_with_function = true

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

# 検索結果一覧の出力(PDF)
configatron.manifestation_list_print_pdf.filename = "manifestation_list.pdf"
# 検索結果一覧の出力(TSV)
configatron.manifestation_list_print_tsv.filename = "manifestation_list.tsv"
# 資料確認票のファイル名
configatron.manifestation_locate_print.filename = "manifestation.pdf"

# 貸出票の出力
configatron.checkouts_print.filename = "checkouts.pdf"
configatron.checkouts_print.message = "本は大事に扱いましょう。期限はきちんと守りましょう。インターネットで延長ができます。"
# 貸出リスト(PDF)の出力
configatron.checkout_list_print_pdf.filename = "checkoutlist.pdf"
# 貸出リスト(TSV)の出力
configatron.checkout_list_print_tsv.filename = "checkoutlist.tsv"
# 貸出リストに利用者の年齢を表示するかどうか
configatron.checkout_print.old = true

# 予約票の出力
configatron.reserve_print.filename = "reserve.pdf"
# 予約リスト(個人)の出力
configatron.reserve_list_user_print.filename = "reserve_list_user.pdf"
# 予約リスト(全体)の出力(PDF)
configatron.reserve_list_all_print_pdf.filename = "reserve_list_all.pdf"
# 予約リスト(全体)の出力(TSV)
configatron.reserve_list_all_print_tsv.filename = "reserve_list_all.tsv"
# 取置済み資料の出力(PDF)
configatron.retained_manifestation_list_print_pdf.filename = "retained_manifestation_list.pdf"
# 取置済み資料の出力(TSV)
configatron.retained_manifestation_list_print_tsv.filename = "retained_manifestation_list.tsv"
# 予約表に利用者の年齢を表示するかどうか
configatron.reserve_print.old = true

# 利用者リストの出力(PDF)
configatron.user_list_print_pdf.filename = "user_list.pdf"
# 利用者リス知の出力(TSV)
configatron.user_list_print_tsv.filename = "user_list.tsv"
# 連絡不可者の出力(PDF)
configatron.unable_list_print_pdf.filename = "unable_list.pdf"
# 連絡不可者の出力(TSV)
configatron.unable_list_print_tsv.filename = "unable_list.tsv"
# 家族リストの出力(PDF)
configatron.family_list_print_pdf.filename = "family_list.pdf"
# 家族リストの出力(TSV)
configatron.family_list_print_tsv.filename = "family_list.tsv"

#購入リクエストの一覧の出力(TSV)
configatron.purchase_requests_print_tsv.filename = "purchase_requests.tsv"

# 督促はがきのファイル名
configatron.reminder_postal_card_print.filename = "reminder_postal_card.pdf"
# 督促はがきの図書館メッセージ（最大全角242文字）
configatron.reminder_postal_card_message = "図書館からお借りになったなった本や視聴覚資料などを、返す日が過ぎております。\n速やかにお返しください。\n\n>・お返しになった後、行き違いにこの手紙が届きましたらご容赦ください。\n・図書館が閉まっているときは、入り口脇のブックポストをご利用ください。\n・視聴覚資料に限りましてはブックポストへの返却はご遠慮いただき、直接カウンターにお返しください。\n・資料を、郵送や宅配便でお返しいただく場合は、壊れないようご配慮の上お送りください。\n・ご不明な点がありましたらお問い合わせください。"
# 督促書のファイル名
configatron.reminder_letter_print.filename = "reminder_letter.pdf"
# 督促書の図書館メッセージ
configatron.reminder_letter_message = "図書館からお借りになったなった本や視聴覚資料などを、返す日が過ぎております。\n速やかにお返しください。\n\n・お返しになった後、行き違いにこの手紙が届きましたらご容赦ください。\n・図書館が閉まっているときは、入り口脇のブックポストをご利用ください。\n・視聴覚資料に限りましてはブックポストへの返却はご遠慮いただき、直接カウンターにお返しください。\n・資料を、郵送や宅配便でお返しいただく場合は、壊れないようご配慮の上お送りください。\n・ご不明な点がありましたらお問い合わせください。"
# 督促情報表のファイル名
configatron.reminder_list_print_pdf.filename = "reminder_list.pdf"
# 督促情報表のファイル名
configatron.reminder_list_print_tsv.filename = "reminder_list.tsv"

#開館日と催し物の一覧の出力(TSV)
configatron.event_list_print_tsv.filename = "event_list.tsv"

# 貸出状況の帳票ファイル名
configatron.checkoutlist_report_pdf.filename = "checkoutlist.pdf"
configatron.checkoutlist_report_tsv.filename = "checkoutlist.tsv"

# 予約状況の帳票ファイル名
configatron.reservelist_report_pdf.filename = "reservelist.pdf"
configatron.reservelist_report_tsv.filename = "reservelist.tsv"

# TSVファイルからの資料インポートの結果の一覧の出力(TSV)
configatron.resource_import_results_print_tsv.filename = "resource_import_results.tsv"
# テキストファイルからの資料インポートの結果の一覧の出力(TSV)
configatron.resource_import_textresults_print_tsv.filename = "resource_import_textresults.tsv"
# 催し物インポートの結果の一覧の出力(TSV)
configatron.event_import_results_print_tsv.filename = "event_import_results.tsv"
# 人物・団体インポートの結果の一覧の出力(TSV)
configatron.patron_import_results_print_tsv.filename = "patron_import_results.tsv"

# 利用者別貸出統計の出力(TSV)
configatron.user_checkout_stats_print_tsv.filename = "user_checkout_stats.tsv"
# 利用者別予約統計の出力(TSV)
configatron.user_reserve_stats_print_tsv.filename = "user_reserve_stats.tsv"
# 資料別貸出統計の出力(TSV)
configatron.manifestation_checkout_stats_print_tsv.filename = "manifestation_checkout_stats.tsv"
# 資料者別予約統計の出力(TSV)
configatron.manifestation_reserve_stats_print_tsv.filename = "manifestation_reserve_stats.tsv"
# ブックマーク統計の出力(TSV)
configatron.bookmark_stat_stats_print_tsv.filename = "bookmark_stat_stats.tsv"

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
configatron.sounds.errors.default = "sounds/missA11.ogg"

# refs 1849 trueの場合=>一般利用者において、在架資料は、図書館利用時に借りることができる。
# 予約対象は貸出中の図書のみ
configatron.reserve.not_reserve_on_loan = false

# refs 2042 蔵書点検時、未返却資料を検出した場合は自動的に返却処理を行う
configatron.library_checks.auto_checkin = true

# refs 2553 ユーザ情報重複チェック機能
configatron.patron.check_duplicate_user = false

# refs 2552 クライアント接続パスフレーズ
configatron.clientkey = "Next-L/Enju:Next-L/Enju:Next-L/E"
# refs 2552 データを暗号化する
configatron.encoding = false

# refs 2601 すべてのユーザに検索結果の一覧の取得が出来るようにする
configatron.manifestations.users_show_output_button = false

# refs 1989 trueの場合 => itemがひとつだけのmanifestationのitemを削除するとき、除籍してからのみ削除できる
configatron.items.confirm_destroy = true

# refs 1991 雑誌最新号の貸出禁止
configatron.checkouts.cannot_for_new_serial = true

# refs 2588 所蔵のない資料の予約
configatron.reserves.able_for_not_item = true

# refs 1978 拡張統計-図書リストの新刊購入受入リスト 出版日がシステム日付からn日前以降であるものを抽出
configatron.new_book_term = 14

# refs 3127 ユーザー権限以下でログイン時、購入リクエスト画面を表示するかどうか。trueのとき表示
configatron.user_show_purchase_requests

# refs 3127 ユーザー権限以下でログイン時、質問(レファレンス)ト画面を表示するかどうか。trueのとき表示
configatron.user_show_questions

# refs 3128 発注リストを使用するかどうか。trueのとき使用可能
configatron.use_order_lists

# 書影
#configatron.manifestation_book_jacket.unknown_resource = "(NO IMAGE)"

# refs 2506 予約受付時に予約者に受付完了メッセージを送信するか
configatron.send_message.reservation_accepted_for_patron = true

# refs 2506 予約受付時に管理者に受付完了メッセージを送信するか
configatron.send_message.reservation_accepted_for_library = true

# refs 2506 予約キャンセル時に予約者にキャンセル完了メッセージを送信するか
configatron.send_message.reservation_canceled_for_patron = true

# refs 2506 予約キャンセル時に管理者にキャンセル完了メッセージを送信するか
configatron.send_message.reservation_canceled_for_library = true

# refs 2506 予約資料確保時に予約者に資料確保完了メッセージを送信するか
configatron.send_message.item_received_for_patron = true

# refs 2506 予約資料確保時に管理者に資料確保完了メッセージを送信するか
configatron.send_message.item_received_for_library = true

# refs 2506 予約資料の有効期限が過ぎた時に利用者に有効期限切れメッセージを送信するか
configatron.send_message.reservation_expired_for_patron = true

# refs 2506 予約資料の有効期限が過ぎた時に管理者に有効期限切れメッセージを送信するか
configatron.send_message.reservation_expired_for_library = true

# refs 2506 貸出資料の督促送信指定日に利用者に督促メッセージを送信するか
configatron.send_message.recall_item = true

# refs 2506 貸出期限切れ資料の督促送信指定日に利用者に督促メッセージを送信するか
configatron.send_message.recall_overdue_item = true

# refs 2506 購入リクエストを受付時に利用者に受付完了メッセージを送信するか
configatron.send_message.purchase_request_accepted = true

# refs 2506 購入リクエスト謝絶時に利用者に謝絶完了メッセージを送信するか
configatron.send_message.purchase_request_rejected = true

# refs 3563 取置き済資料が貸出不可になったとき利用者に取置き取消メッセージを送信するか
configatron.send_message.reserve_reverted_for_patron = true

# refs 3563 取置き済資料が貸出不可になったとき管理者に取置き取消メッセージを送信するか
configatron.send_message.reserve_reverted_for_library = true

# 請求記号の先頭文字がセパレータのとき先頭文字を削除するか
configatron.items.call_number.delete_first_delimiter = true

# refs 3861資料の検索時、キーワードがスペースで区切られている場合はそれぞれの語によってAND検索を行うか
configatron.search.use_and = true

# refs 3861 資料の詳細検索時、各項目に関しANDで検索を行うか
configatron.advanced_search.use_and = true

# refs 3806 資料の検索結果一覧の表示件数のセレクタ値
configatron.manifestations.per_page = '10, 20, 50, 100'
