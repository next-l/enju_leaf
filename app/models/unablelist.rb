class Unablelist < ActiveRecord::Base

  def self.get_unable_list_pdf(users, sort)
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
    return report
  end

  def self.get_unable_list_tsv(users)
    data = String.new
    data << "\xEF\xBB\xBF".force_encoding("UTF-8") + "\n"

    columns = [
      [:library, 'activerecord.attributes.user.library'],
      [:user_number, 'activerecord.attributes.user.user_number'],
      [:full_name, 'activerecord.attributes.patron.full_name'],
      [:telephone_number_1, 'activerecord.attributes.patron.telephone_number_1'],
      [:extelephone_number_1, 'activerecord.attributes.patron.extelephone_number_1'],
      [:fax_number_1, 'activerecord.attributes.patron.fax_number_1'],
      [:birth, 'activerecord.attributes.patron.date_of_birth'],
      [:email, 'activerecord.attributes.patron.email'],
    ]

    # title column
    row = columns.map {|column| I18n.t(column[1])}
    data << '"'+row.join("\"\t\"")+"\"\n"

    users.each do |user|
      row = []
      columns.each do |column|
        case column[0]
        when :library
          row << user.library.display_name
        when :user_number
          row << user.user_number
        when :full_name
          row << user.patron.full_name
        when :telephone_number_1
          row << user.patron.telephone_number_1
        when :extelephone_number_1
          row << user.patron.extelephone_number_1
        when :fax_number_1
          row << user.patron.fax_number_1
        when :birth
          row << user.patron.date_of_birth.strftime("%Y/%m/%d") if user.patron.date_of_birth
        when :email
          row << user.patron.email
        else
          row << get_object_method(user, column[0].split('.')).to_s.gsub(/\r\n|\r|\n/," ").gsub(/\"/,"\"\"")
        end
      end
      data << '"'+row.join("\"\t\"")+"\"\n"
    end
    return data
  end
end
