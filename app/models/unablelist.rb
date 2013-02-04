class Unablelist < ActiveRecord::Base

  paginates_per 10

  def self.get_unable_list_pdf(users, sort)
    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'userlist.tlf')
    # set page_num
    report.events.on :page_create do |e|
      e.page.item(:page).value(e.page.no)
    end
    report.events.on :generate do |e|
      e.pages.each do |page|
        page.item(:list_title).value(I18n.t('page.listing', :model => I18n.t('activerecord.models.unablelist')))
        page.item(:total).value(e.report.page_count)
      end
    end

    # set data
    report.start_new_page do |page|
      page.item(:date).value(Time.now)
      if sort == 'created_at'
        page.item(:sort).value(I18n.t('activerecord.attributes.unablelist.output_format')+": " + I18n.t('page.created_at'))
      else
        page.item(:sort).value(I18n.t('activerecord.attributes.unablelist.output_format')+": " + I18n.t("activerecord.attributes.user.#{ sort }"))
      end

      if users.size > 0
        before_library = nil
        users.each do |user|
          page.list(:list).add_row do |row|
            if sort == 'library' and before_library == user.library
              row.item(:library_line).hide
              row.item(:library).hide
            end
            row.item(:full_name).value(user.try(:patron).try(:full_name))
#            row.item(:username).value(user.username)
            row.item(:department).value(user.try(:department).try(:display_name))
            row.item(:user_number).value(user.user_number)
            row.item(:tel1).value(user.try(:patron).try(:telephone_number_1)) if user.try(:patron).try(:telephone_number_1)
            row.item(:e_mail).value(user.try(:patron).try(:email)) if user.try(:patron).try(:email)
            row.item(:created_at).value(user.created_at)
            if user.active_for_authentication?
              row.item(:user_status).value(user.try(:user_status).try(:display_name))
            else
              row.item(:user_status).value(user.try(:user_status).try(:display_name) + "#{I18n.t('activerecord.attributes.user.locked_no')}")
            end
            row.item(:unable).value(I18n.t('activerecord.attributes.user.unable_yes')) unless user.unable
            row.item(:unable).value(I18n.t('activerecord.attributes.user.unable_no')) if user.unable
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
#      [:library, 'activerecord.attributes.user.library'],
      ['user_number', 'activerecord.attributes.user.user_number'],
      [:full_name, 'activerecord.attributes.patron.full_name'],
      [:department, 'activerecord.attributes.user.department'],
      [:telephone_number_1, 'activerecord.attributes.patron.telephone_number_1'],
#      [:extelephone_number_1, 'activerecord.attributes.patron.extelephone_number_1'],
      [:email, 'activerecord.attributes.patron.email'],
#      [:fax_number_1, 'activerecord.attributes.patron.fax_number_1'],
#      [:birth, 'activerecord.attributes.patron.date_of_birth'],
    ]

    # title column
    row = columns.map { |column| I18n.t(column[1]) }
    data << '"'+row.join("\"\t\"")+"\"\n"
    # data
    users.each do |user|
      row = []
      columns.each do |column|
        case column[0]
        when :library
          row << user.try(:library).try(:display_name)
        when :full_name
          row << user.try(:patron).try(:full_name)
        when :telephone_number_1
          row << user.try(:patron).try(:telephone_number_1)
        when :extelephone_number_1
          row << user.try(:patron).try(:extelephone_number_1)
        when :fax_number_1
          row << user.try(:patron).try(:fax_number_1)
        when :birth
          row << user.patron.date_of_birth.strftime("%Y/%m/%d") if user.try(:patron).try(:date_of_birth)
        when :email
          row << user.try(:patron).try(:email)
        when :department
          row << user.try(:department).try(:display_name)
        else
          row << get_object_method(user, column[0].split('.')).to_s.gsub(/\r\n|\r|\n/," ").gsub(/\"/,"\"\"")
        end
      end
      data << '"'+row.join("\"\t\"")+"\"\n"
    end
    return data
  end

  private
  def self.get_object_method(obj,array)
    _obj = obj.send(array.shift)
    return get_object_method(_obj, array) if array.present?
    return _obj
  end
end
