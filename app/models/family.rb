class Family < ActiveRecord::Base
  has_many :users, :through => :family_users
  has_many :family_users

  def add_user(user_ids)
    # TODO :need refactoring
    logger.info "aaa"
    user_ids.delete_if{|u| u.blank?} if user_ids
    if user_ids.nil? || user_ids.empty? 
      logger.debug "family users no record"
      errors.add(:base, I18n.t('family.no_select_users'))
      raise 
    end

    #
    user_ids.each do |user_id|
      self.users << User.find(user_id) rescue nil
    end
  end

  def self.output_familylist_pdf(families)
    max_family_column = 7
    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'familylist.tlf')

    # set page_num
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

      before_family_id = nil
      families.each do |family|
        # get rows
        start = 0
        rows = Array.new
        while family.users.size > start
          rows  << family.users.slice(start, max_family_column)
          start += max_family_column 
        end
        # set rows
        rows.each do |users|
          page.list(:list).add_row do |row|
            row.item(:id).value(family.id) unless family.id == before_family_id
            row.item(:line_id).hide if family.id == before_family_id
            row.item(:line_member).style(:border_width, 0.5) if family.id == before_family_id
            row.item(:line_member).style(:border_color, '#bfbfbf') if family.id == before_family_id
            users.each_with_index do |user, i|
              row.item("member#{i}").value(user.patron.full_name) 
            end
          end
          before_family_id = family.id
        end
      end
    end
    return report
  end

  def self.output_familylist_tsv(families)
    data = String.new
    data << "\xEF\xBB\xBF".force_encoding("UTF-8") + "\n"

    # title column
    row = []
    row << I18n.t('activerecord.attributes.family.id')
    max_family = 1
    families.each do |family|
      max_family = family.users.size if max_family < family.users.size
    end
    for i in 1..max_family do
      row << I18n.t('family.members') + i.to_s
    end
    data << '"'+row.join("\"\t\"")+"\"\n"

    # detail
    families.each do |family|
      row = []
      row << family.id
      family.users.each do |user|
        row << user.patron.full_name
      end
      data << '"'+row.join("\"\t\"")+"\"\n"
    end
    return data
  end
end
