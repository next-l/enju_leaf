class RetainedManifestation < ActiveRecord::Base
  self.extend ReservesHelper

  def self.get_retained_manifestation_list_pdf(retained_manifestations)
    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'retained_manifestations.tlf')

    # set page num
    report.events.on :page_create do |e|
      e.page.item(:page).value(e.page.no)
    end
    report.events.on :generate do |e|
      e.pages.each do |page|
        page.item(:total).value(e.report.page_count)
      end
    end
    # set 
    report.start_new_page do |page|
      page.item(:date).value(Time.now)
      before_user = nil
      before_receipt_library = nil
      if retained_manifestations.size > 0
        retained_manifestations.each do |r|
          page.list(:list).add_row do |row|
            if before_user == r.user_id
              row.item(:line1).hide
              row.item(:user).hide
            end
            if before_receipt_library == r.receipt_library_id and before_user == r.user_id
              row.item(:line2).hide
              row.item(:receipt_library).hide
            end
            row.item(:receipt_library).value(Library.find(r.receipt_library_id).display_name)
            row.item(:title).value(r.manifestation.original_title)
            disp_name = r.user.patron.full_name
            if SystemConfiguration.get("reserve_print.old") == true and  r.user.patron.date_of_birth
              age = (Time.now.strftime("%Y%m%d").to_f - r.user.patron.date_of_birth.strftime("%Y%m%d").to_f) / 10000
              age = age.to_i
              disp_name = disp_name + '(' + age.to_s + I18n.t('activerecord.attributes.patron.old')  +')'
            end
            row.item(:user).value(disp_name)
            information_type = I18n.t(i18n_information_type(r.information_type_id).strip_tags)
            unless r.information_type_id == Reserve.unnecessary_type_ids
              information_type += ': '
              information_type += Reserve.get_information_type(r) unless Reserve.get_information_type(r).blank?
            end
            row.item(:information_type).value(information_type)
          end
          before_user = r.user_id
          before_receipt_library = r.receipt_library_id
        end
      end
    end
    return report
  end

  def self.get_retained_manifestation_list_tsv(retained_manifestations)
    data = String.new
    data << "\xEF\xBB\xBF".force_encoding("UTF-8") + "\n"
    columns = [
      [:user, 'activerecord.attributes.reserve.user'],
      [:receipt_library, 'activerecord.attributes.reserve.receipt_library'],
      [:title, 'activerecord.attributes.manifestation.original_title'],
      [:information_type, 'activerecord.attributes.reserve.information_type']
    ]

    # title column
    row = columns.map {|column| I18n.t(column[1])}
    data << '"'+row.join("\"\t\"")+"\"\n"  

    retained_manifestations.each do |reserve|
      row = []
      columns.each do |column|
        case column[0]
        when :user
          disp_name = reserve.user.patron.full_name
          if SystemConfiguration.get("reserve_print.old") == true and  reserve.user.patron.date_of_birth
            age = (Time.now.strftime("%Y%m%d").to_f - reserve.user.patron.date_of_birth.strftime("%Y%m%d").to_f) / 10000
            age = age.to_i
            disp_name = disp_name + '(' + age.to_s + I18n.t('activerecord.attributes.patron.old')  +')'
          end
          row << disp_name
        when :receipt_library
          row << Library.find(reserve.receipt_library_id).display_name
        when :title
          row << reserve.manifestation.original_title
        when :information_type
          information_type = I18n.t(i18n_information_type(reserve.information_type_id).strip_tags)
          unless reserve.information_type_id == Reserve.unnecessary_type_ids
            information_type += ': '
            information_type += Reserve.get_information_type(reserve) unless Reserve.get_information_type(reserve).blank?
          end
          row << information_type
        end
      end
      data << '"'+row.join("\"\t\"")+"\"\n"  
    end
    return data  
  end
end
