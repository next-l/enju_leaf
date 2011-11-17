class UnablelistController < ApplicationController
  def index
    return access_denied unless (user_signed_in? and current_user.has_role?('Librarian'))

    sort = 'user_number asc'
    case params[:sort_by]
    when 'library'
      sort = 'library_id asc, user_number asc'
    end
    @users = User.where(:unable => true).order(sort)
  end

  def output
    return access_denied unless (user_signed_in? and current_user.has_role?('Librarian'))

    sort = 'user_number asc'
    sort_by = t('activerecord.attributes.user.user_number')
    if params[:sort_by] == 'library'
      sort = 'library_id asc, user_number asc'
      sort_by = t('activerecord.attributes.user.library')
    end 
    users = User.where(:unable => true).order(sort)
    
    require 'thinreports'
    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'unablelist.tlf')

    report.events.on :page_create do |e|
      e.page.item(:page).value(e.page.no)
    end
    report.events.on :generate do |e|
      e.pages.each do |page|
        page.item(:total).value(e.report.page_count)
      end
    end

    report.start_new_page do |page|
      page.item(:date).value(Time.now)
      page.item(:sort).value(t('activerecord.attributes.unablelist.output_format')+":"+sort_by)

      before_library = nil
      users.each do |user|
        page.list(:list).add_row do |row|
          if params[:sort_by] == 'library' and before_library == user.library
           row.item(:library_line).hide
           row.item(:library).hide
          end
          row.item(:library).value(user.library.display_name)
          row.item(:user_number).value(user.user_number)
          row.item(:full_name).value(user.patron.full_name)
          row.item(:tel1).value(user.patron.telephone_number_1)
          row.item(:tel2).value(user.patron.extelephone_number_1)
          row.item(:tel3).value(user.patron.fax_number_1)
          row.item(:birth).value(user.patron.date_of_birth)
          row.item(:email).value(user.patron.email)
        end
        before_library = user.library
      end
    end

    send_data report.generate, :filename => configatron.unablelist_print.filename, :type => 'application/pdf', :disposition => 'attachment'
  end
end
