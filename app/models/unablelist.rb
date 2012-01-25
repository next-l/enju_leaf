class Unablelist < ActiveRecord::Base

  def self.output(users, sort, file)
    #out_dir = "#{RAILS_ROOT}/private/system/users/"
    #FileUtils.mkdir_p(out_dir) unless FileTest.exist?(out_dir)
    #file = out_dir + configatron.unablelist_print.filename
    logger.info "output unablelist"

    require 'thinreports'
    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'unablelist.tlf')

    # set page_num
    report.events.on :page_create do |e|
      e.page.item(:page).value(e.page.no)
    end
    report.events.on :generate do |e|
      e.pages.each do |page|
        page.item(:total).value(e.report.page_count)
      end
    end

    # set data
    report.start_new_page do |page|
      page.item(:date).value(Time.now)
      case sort
      when sort = 'library'
        page.item(:sort).value(I18n.t('activerecord.attributes.unablelist.output_format')+": " + I18n.t('activerecord.attributes.user.library'))
      else
        page.item(:sort).value(I18n.t('activerecord.attributes.unablelist.output_format')+": " + I18n.t('activerecord.attributes.user.user_number'))
      end
      if users.size > 0
        before_library = nil
        users.each do |user|
          page.list(:list).add_row do |row|
            if sort == 'library' and before_library == user.library
             row.item(:library_line).hide
             row.item(:library).hide
            end
            row.item(:library).value(user.library.display_name)
            row.item(:user_number).value(user.user_number) if user.user_number
            row.item(:full_name).value(user.patron.full_name)
            row.item(:tel1).value(user.patron.telephone_number_1)
            row.item(:tel2).value(user.patron.extelephone_number_1)
            row.item(:tel3).value(user.patron.fax_number_1)
            row.item(:birth).value(user.patron.date_of_birth)
            row.item(:email).value(user.patron.email)
          end
          before_library = user.library
        end
      else
        page.list(:list).add_row do |row|
            row.item(:not_found).show
            row.item(:not_found).value(I18n.t('page.not_found_users'))
            row.item(:line0).hide
            row.item(:line1).hide
            row.item(:line2).hide
            row.item(:line3).hide
            row.item(:line4).hide
            row.item(:line5).hide
            row.item(:line6).hide
        end 
      end
    end
    report.generate_file(file)
  end
end
