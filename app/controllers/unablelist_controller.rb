class UnablelistController < ApplicationController
  def index
    sort = 'user_number asc'
    case params[:sort_by]
    when 'library'
      sort = 'library_id asc, user_number asc'
    end
    @users = User.where(:unable => true).order(sort)
  end

  def output
    sort = 'user_number asc'
    sort_by = t('activerecord.attributes.user.user_number')
    if params[:sort_by] == 'library'
      sort = 'library_id asc, user_number asc'
      sort_by = t('activerecord.attributes.user.library')
    end 
    users = User.where(:unable => true).order(sort)
    
    require 'thinreports'
    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'unablelist.tlf')

    report.layout.config.list(:list) do
      use_stores :page_num => 0 

      events.on :page_footer_insert do |e|
        e.store.page_num +=1;
        e.section.item(:page_num).value(e.store.page_num)
      end
    end

    report.start_new_page do |page|
      page.item(:date).value(Time.now)
      page.item(:sort).value(t('activerecord.attributes.unablelist.output_format')+":"+sort_by)

      users.each do |user|
        page.list(:list).add_row do |row|
          row.item(:library).value(user.library.display_name)
          row.item(:user_number).value(user.user_number)
          row.item(:full_name).value(user.patron.full_name)
          row.item(:tel1).value(user.patron.telephone_number_1)
          row.item(:tel2).value(user.patron.extelephone_number_1)
          row.item(:tel3).value(user.patron.fax_number_1)
          row.item(:birth).value(user.patron.date_of_birth)
          row.item(:email).value(user.patron.email)
        end
      end
    end
    send_data report.generate, :filename => configatron.unablelist_print.filename, :type => 'application/pdf', :disposition => 'attachment'
  end
end
