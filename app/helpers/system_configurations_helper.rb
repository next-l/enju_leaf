module SystemConfigurationsHelper
  def system_configuration_categories
    system_configuration_categories = [
      'general', 
      'user', 
      'manifestation', 
      'checkout', 
      'checkin', 
      'reserve', 
      'purchase_request',
      'question', 
      'order_list',
      'copy_request',
      'reminder', 
      'statistics', 
      'sound', 
      'view',
      'nacsis',
    ]
  end

  def i18n_system_configuration_categories(category)
    case category
    when 'general'
      t('system_configuration.general')
    when 'user'
      t('system_configuration.user')
    when 'manifestation'
      t('system_configuration.manifestation')
    when 'checkout'
      t('system_configuration.checkout')
    when 'checkin'
      t('system_configuration.checkin')
    when 'reserve'
      t('system_configuration.reserve')
    when 'purchase_request'
      t('system_configuration.purchase_request')
    when 'question'
      t('system_configuration.question')
    when 'order_list'
      t('system_configuration.order_list')
    when 'copy_request'
      t('system_configuration.copy_request')
    when 'reminder'
      t('system_configuration.reminder')
    when 'statistics'
      t('system_configuration.statistics')
    when 'sound'
      t('system_configuration.sound')
    when 'view'
      t('system_configuration.view')
    when 'nacsis'
      t('system_configuration.nacsis')
    end
  end

  def make_form(system_configuration, errors = nil)
    #TODO:
    error = nil
    if errors
      errors.each do |e|
        error = e if e.id.to_i == system_configuration.id
      end
    end

    string = ''
    case system_configuration.typename
    when 'Text'
      string << "<textarea name=system_configurations[#{ system_configuration.id }]"
      string << " style='background-color:pink;'" if error
      string << ">"
      if error
        string << error.v
      else
        string << system_configuration.v
      end
      string << "</textarea>"
    when 'String', 'Numeric'
      case system_configuration.keyname
      when 'header.disp_date',
           'user.locked.background',
           'user.unable.background',
           'purchase_request.can_use'
        string = make_form_selector(string, system_configuration)
      else
        string << "<input type='text' "
        string << "name=system_configurations[#{ system_configuration.id }] "
        if error
          string << "value='#{ error.v }' "
        else
          string << "value='#{ system_configuration.v }' "
        end
        string << "style='background-color:pink;'" if error
        string << ">"
      end
    when 'Boolean'
      string = make_form_boolean(string, system_configuration)
    end
    string.html_safe
  end

 def make_form_selector(string, system_configuration)
   string << "<select name=system_configurations[#{ system_configuration.id }]>"
   case system_configuration.keyname
   when 'header.disp_date'
     3.times do |i|
       string << "<option value=#{i} "
       string << "selected='selected'" if system_configuration.v.to_i == i
       string << ">"
       string << t('system_configuration.disp_date.not_display') if i == 0
       string << t('system_configuration.disp_date.christian_era') if i == 1
       string << t('system_configuration.disp_date.japanese_era') if i == 2
       string << "</option>"
     end
   when 'user.locked.background', 'user.unable.background'
     ['white', 'lightgrey', 'skyblue', 'springgreen', 'yellow', 'pink'].each do |c|
       string << "<option value=#{c} "
       string << "selected='selected'" if system_configuration.v == c
       string << ">"
       string << t('system_configuration.color.skyblue') if c == 'skyblue'
       string << t('system_configuration.color.springgreen') if c == 'springgreen'
       string << t('system_configuration.color.yellow') if c == 'yellow'
       string << t('system_configuration.color.pink') if c == 'pink'
       string << t('system_configuration.color.red') if c == 'red'
       string << t('system_configuration.color.lightgrey') if c == 'lightgrey'
       string << t('system_configuration.color.white') if c == 'white'
       string << "</option>"
     end    
   when 'purchase_request.can_use'
     string << "<option value='' "
     string << "selected='selected'" if system_configuration.v == ""
     string << ">"
     string << t('system_configuration.role.all')
     string << "</option>"
     @roles.each do |role|
       string << "<option value=#{ role.name } "
       string << "selected='selected'" if system_configuration.v == role.name
       string << ">"
       string << role.display_name
       string << "</option>"
     end
   end
   string << "</select>" 
   return string
 end 

 def make_form_boolean(string, system_configuration)
   ['true', 'false'].each do |state|
     string << "<input type=radio
                       name=system_configurations[#{ system_configuration.id }]
                       value=#{state} "
     string << "checked='checked'" if system_configuration.v == state
     string << ">"
     target = ''

     # set action
     case system_configuration.keyname
     # => display
     when 'disp_alert_when_move_page_with_function',
          'family_name_first',
          'manifestation.display_checkouts_count',
          'manifestation.display_reserves_count',
          'manifestation.display_last_checkout_datetime',
          'user_show_purchase_requests',
          'user_show_questions',
          'checked_items.disp_title',
          'checked_items.disp_user',
          'checkout_print.old',
          'checkins.disp_title',
          'checkins.disp_user',
          'view.pick_up',
          'view.tag_cloud',
          'view.top_query_detail',
          'view.events',
          'view.checkout.disp_reserves',
          'view.checkout.disp_checkouts',
          'reserve_print.old'
       string << t('system_configuration.boolean_display') if state == 'true'
       string << t('system_configuration.boolean_not_display') if state == 'false'
     # => do
     when 'patron.check_duplicate_user',
          'library_checks.auto_checkin',
          'no_operation_logout'
       string << t('system_configuration.boolean_do') if state == 'true'
       string << t('system_configuration.boolean_not_do') if state == 'false'
     # => yes,no
     when 'auto_user_number', 'manifestations.split_by_type', 'manifestations.google_book_search_preview', 
          'checkout.auto_checkin', 'manifestation.manage_item_rank', 'use_inter_library_loan', 'use_family', 'use_birth_day',
          'manifestation.has_one_item', 'manifestation.isbn_unique', 'user_change_department',
          'checkout.set_extending_due_date_before_closing_day', 'manifestation.social_bookmark'
       string << t('system_configuration.boolean_yes') if state == 'true'
       string << t('system_configuration.boolean_no') if state == 'false'
     # => send
     when 'send_message.recall_item',
          'send_message.recall_overdue_item',
          'send_message.purchase_request_accepted_for_patron',
          'send_message.purchase_request_accepted_for_library',
          'send_message.purchase_request_rejected',
          'send_message.reservation_accepted_for_patron',
          'send_message.reservation_accepted_for_library',
          'send_message.reservation_canceled_for_patron',
          'send_message.reservation_canceled_for_library',
          'send_message.item_received_for_patron',
          'send_message.item_received_for_library',
          'send_message.reservation_expired_for_patron',
          'send_message.reservation_expired_for_library',
          'send_message.reserve_reverted_for_patron',
          'send_message.reserve_reverted_for_library'
       string << t('system_configuration.boolean_send') if state == 'true'
       string << t('system_configuration.boolean_not_send') if state == 'false'
     # => use
     when 'use_order_lists',
          'use_copy_request',
          'nacsis.can_use'
       string << t('system_configuration.boolean_use') if state == 'true'
       string << t('system_configuration.boolean_not_use') if state == 'false'
     # => delete
     when 'items.call_number.delete_first_delimiter'
       string << t('system_configuration.boolean_delete') if state == 'true'
       string << t('system_configuration.boolean_not_delete') if state == 'false'
     # => disable
     when 'checkouts.cannot_for_new_serial'
       string << t('system_configuration.boolean_disable') if state == 'true'
       string << t('system_configuration.boolean_not_disable') if state == 'false'
     # => print
     when 'checkouts_print.auto_print',
          'reserve_print.auto_print',
          'manifestation_print.auto_print'
       string << t('system_configuration.boolean_autoprint') if state == 'true'
       string << t('system_configuration.boolean_not_autoprint') if state == 'false'
     # => other
     when 'manifestations.users_show_output_button'
       string << t('system_configuration.boolean_output_button_all') if state == 'true'
       string << t('system_configuration.boolean_output_button_librarian') if state == 'false'
     when 'items.confirm_destroy'
       string << t('system_configuration.boolean_item_remove') if state == 'true'
       string << t('system_configuration.boolean_item_destroy') if state == 'false'
     when 'write_search_log_to_file'
       string << t('system_configuration.boolean_file') if state == 'true'
       string << t('system_configuration.boolean_db') if state == 'false'
     when 'search.use_and',
          'advanced_search.use_and'
       string << t('system_configuration.boolean_and') if state == 'true'
       string << t('system_configuration.boolean_or') if state == 'false'
     when 'reserve.not_reserve_on_loan'
       string << t('system_configuration.boolean_reserve_only_checkout_item') if state == 'true'
       string << t('system_configuration.boolean_reserve_all_item') if state == 'false'
     when 'reserves.able_for_not_item'
       string << t('system_configuration.boolean_reserve_able_for_not_item') if state == 'true'
       string << t('system_configuration.boolean_reserve_not_able_for_not_item') if state == 'false'
     when 'internal_server'
       string << t('system_configuration.boolean_yes') if state == 'true'
       string << t('system_configuration.boolean_no_opac') if state == 'false'
     when 'checkout.set_rental_certificate_size'
       string << t('system_configuration.boolean_rental_certificate_size') if state == 'true'
       string << t('system_configuration.boolean_not_rental_certificate_size') if state == 'false'
     when 'set_output_format_type'
       string << t('system_configuration.boolean_output_format_type') if state == 'true'
       string << t('system_configuration.boolean_not_output_format_type') if state == 'false'
     end

     string << "<br />" if state == 'true'
   end
   return string
 end
end
