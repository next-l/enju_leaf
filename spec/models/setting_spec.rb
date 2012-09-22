# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Setting do
  it "not exist key should be raise exception" do
#    Setting.not_exist_key.should raise_error(MissingSetting)
  end

  it "default setting enju group" do
    Setting.enju.web_hostname.should == "localhost"
    Setting.enju.web_port_number.should == 3000
    Setting.header.disp_date.should == 2
    Setting.disp_alert_when_move_page_with_function.should be_true
    Setting.family_name_first.should be_true
    Setting.max_number_of_results.should == 500
    Setting.write_search_log_to_file.should be_true
    Setting.csv_charset_conversion.should be_true
    Setting.amazon.aws_hostname.should == 'ecs.amazonaws.jp'
    Setting.amazon.hostname.should == 'www.amazon.co.jp'
    Setting.book_jacket.source.should == :google
    Setting.screenshot.generator.should == :mozshot
    Setting.checkins.disp_title.should be_true
    Setting.checkins.disp_user.should be_true
    Setting.checked_items.disp_title.should be_true
    Setting.checked_items.disp_user.should be_true
    Setting.resource_import_template.should == "templates/resource_import_template.zip"
    Setting.no_operation_counter.should == 0
    Setting.manifestation_list_print_pdf.filename.should == "manifestation_list.pdf"
    Setting.manifestation_list_print_tsv.filename.should == "manifestation_list.tsv"
    Setting.manifestation_locate_print.filename.should == "manifestation.pdf"
    Setting.checkouts_print.filename.should == "checkouts.pdf"
    Setting.checkouts_print.message.nil?.should be_false
    Setting.checkout_list_print_pdf.filename.should == "checkoutlist.pdf"
    Setting.checkout_list_print_tsv.filename.should == "checkoutlist.tsv"
    Setting.checkout_print.old.should be_true

    Setting.reserve_print.filename.should == "reserve.pdf"
    Setting.reserve_list_user_print.filename.should == "reserve_list_user.pdf"
    Setting.reserve_list_all_print_pdf.filename.should == "reserve_list_all.pdf"
    Setting.reserve_list_all_print_tsv.filename.should == "reserve_list_all.tsv"
    Setting.retained_manifestation_list_print_pdf.filename.should == "retained_manifestation_list.pdf"
    Setting.retained_manifestation_list_print_tsv.filename.should == "retained_manifestation_list.tsv"
    Setting.reserve_print.old.should be_true

    Setting.user_list_print_pdf.filename.should == "user_list.pdf"
    Setting.user_list_print_tsv.filename.should == "user_list.tsv"
    Setting.unable_list_print_pdf.filename.should == "unable_list.pdf"
    Setting.unable_list_print_tsv.filename.should == "unable_list.tsv"
    Setting.family_list_print_pdf.filename.should == "family_list.pdf"
    Setting.family_list_print_tsv.filename.should == "family_list.tsv"

    Setting.purchase_requests_print_tsv.filename.should == "purchase_requests.tsv"
    Setting.reminder_postal_card_print.filename.should == "reminder_postal_card.pdf"
    Setting.reminder_postal_card_message.nil?.should be_false
    Setting.reminder_letter_print.filename.should == "reminder_letter.pdf"
    Setting.reminder_letter_message.nil?.should be_false
    Setting.reminder_list_print_pdf.filename.should == "reminder_list.pdf"
    Setting.reminder_list_print_tsv.filename.should == "reminder_list.tsv"

    Setting.event_list_print_tsv.filename.should == "event_list.tsv"
    Setting.checkoutlist_report_pdf.filename.should == "checkoutlist.pdf"
    Setting.checkoutlist_report_tsv.filename.should == "checkoutlist.tsv"
    Setting.reservelist_report_pdf.filename.should == "reservelist.pdf"
    Setting.reservelist_report_tsv.filename.should == "reservelist.tsv"

    Setting.resource_import_results_print_tsv.filename.should == "resource_import_results.tsv"
    Setting.resource_import_textresults_print_tsv.filename.should == "resource_import_textresults.tsv"
    Setting.event_import_results_print_tsv.filename.should == "event_import_results.tsv"
    Setting.patron_import_results_print_tsv.filename.should == "patron_import_results.tsv"
    Setting.user_checkout_stats_print_tsv.filename.should == "user_checkout_stats.tsv"
    Setting.user_reserve_stats_print_tsv.filename.should == "user_reserve_stats.tsv"
    Setting.manifestation_checkout_stats_print_tsv.filename.should == "manifestation_checkout_stats.tsv"
    Setting.manifestation_reserve_stats_print_tsv.filename.should == "manifestation_reserve_stats.tsv"
    Setting.bookmark_stat_stats_print_tsv.filename.should == "bookmark_stat_stats.tsv"

    Setting.statistic_report.monthly.should == "monthly_report.pdf"
    Setting.statistic_report.monthly_tsv.should == "monthly_report.tsv"
    Setting.statistic_report.daily.should == "daily_report.pdf"
    Setting.statistic_report.daily_tsv.should == "daily_report.tsv"
    Setting.statistic_report.timezone.should == "timezone_report.pdf"
    Setting.statistic_report.timezone_tsv.should == "timezone_report.tsv"
    Setting.statistic_report.day.should == "day_report.pdf"
    Setting.statistic_report.day_tsv.should == "day_report.tsv"
    Setting.statistic_report.age.should == "age_report.pdf"
    Setting.statistic_report.age_tsv.should == "age_report.tsv"
    Setting.statistic_report.items.should == "items_report.pdf"
    Setting.statistic_report.items_tsv.should == "items_report.tsv"
    Setting.statistic_report.inout_items.should == "inout_items_report.pdf"
    Setting.statistic_report.inout_items_tsv.should == "inout_items_report.tsv"
    Setting.statistic_report.loans.should == "loans_report.pdf"
    Setting.statistic_report.loans_tsv.should == "loans_report.tsv"
    Setting.statistic_report.groups.should == "groups_report.pdf"
    Setting.statistic_report.groups_tsv.should == "groups_report.tsv"
    Setting.statistic_report.open.should == 8
    Setting.statistic_report.hours.should == 14 

    Setting.manifestation.display_checkouts_count.should be_true
    Setting.manifestation.display_reserves_count.should be_true
    Setting.manifestation.display_last_checkout_datetime.should be_true
    Setting.user.locked.background.should == "aqua"
    Setting.user.unable.background.should == "yellow"

    Setting.sounds.basedir.should == "sounds/"
    Setting.sounds.errors.item.this_item_is_reserved.should == "missA11.ogg"
    Setting.sounds.errors.checkin.not_checkin.should == "chimeA08.ogg"
    Setting.sounds.errors.checkin.already_checked_in.should == "missA11.ogg"
    Setting.sounds.errors.checkin.overdue_item.should == "missA11.ogg"
    Setting.sounds.errors.checkin.not_available_for_checkin.should == "churchA08.ogg"
    Setting.sounds.errors.checkin.other_library_item.should == "chimeA08.ogg"
    Setting.sounds.errors.checked_item.already_checked_out.should == "missA11.ogg"
    Setting.sounds.errors.checked_item.not_available_for_checkout.should == "churchA08.ogg"
    Setting.sounds.errors.checked_item.this_group_cannot_checkout.should == "churchA08.ogg"
    Setting.sounds.errors.checked_item.in_transcation.should == "chimeA08.ogg"
    Setting.sounds.errors.checked_item.reserved_item_included.should == "chimeA08.ogg"
    Setting.sounds.errors.default.should == "sounds/missA11.ogg"

    Setting.reserve.not_reserve_on_loan.should be_false
    Setting.library_checks.auto_checkin.should be_true
    Setting.patron.check_duplicate_user.should be_false
    Setting.standaloneclient.clientkey.should == "Next-L/Enju:Next-L/Enju:Next-L/E"
    Setting.standaloneclient.encoding.should be_false
    Setting.manifestations.users_show_output_button.should be_false
    Setting.items.confirm_destroy.should  be_true
    Setting.checkouts.cannot_for_new_serial.should be_true
    Setting.reserves.able_for_not_item.should be_true
    Setting.new_book_term.should == 14
    Setting.user_show_purchase_requests.nil?.should be_false
    Setting.user_show_questions.nil?.should be_false
    Setting.use_order_lists.nil?.should be_false

    Setting.manifestation_book_jacket.unknown_resource.should == "(NO IMAGE)"
    Setting.send_message.reservation_accepted_for_patron.should be_true
    Setting.send_message.reservation_accepted_for_library.should  be_true
    Setting.send_message.reservation_canceled_for_patron.should be_true
    Setting.send_message.reservation_canceled_for_library.should be_true
    Setting.send_message.item_received_for_patron.should be_true
    Setting.send_message.item_received_for_library.should be_true
    Setting.send_message.reservation_expired_for_patron.should be_true
    Setting.send_message.reservation_expired_for_library.should be_true
    Setting.send_message.recall_item.should be_true
    Setting.send_message.recall_overdue_item.should be_true
    Setting.send_message.purchase_request_accepted.should be_true
    Setting.send_message.purchase_request_rejected.should be_true
    
    # # refs 3563 取置き済資料が貸出不可になったとき利用者に取置き取消メッセージを送信するか
    # configatron.send_message.reserve_reverted_for_patron = true
    # configatron.send_message.reserve_reverted_for_library = true
    # configatron.items.call_number.delete_first_delimiter = true
    # configatron.search.use_and = true
    # configatron.advanced_search.use_and = true
    # configatron.manifestations.per_page = '10, 20, 50, 100'
  end
end

