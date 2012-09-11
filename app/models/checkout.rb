class Checkout < ActiveRecord::Base
  self.extend ItemsHelper
  default_scope :order => 'due_date ASC, id DESC'#:order => 'id DESC'
  scope :not_returned, where(:checkin_id => nil)
  scope :overdue, lambda {|date| {:conditions => ['checkin_id IS NULL AND due_date < ?', date]}}
  scope :due_date_on, lambda {|date| where(:checkin_id => nil, :due_date => date.beginning_of_day .. date.end_of_day)}
  scope :completed, lambda {|start_date, end_date| {:conditions => ['created_at >= ? AND created_at < ?', start_date, end_date]}}
  scope :on, lambda {|date| {:conditions => ['created_at >= ? AND created_at < ?', date.beginning_of_day, date.tomorrow.beginning_of_day]}}

  belongs_to :user #, :counter_cache => true #, :validate => true
  delegate :username, :user_number, :to => :user, :prefix => true
  belongs_to :item #, :counter_cache => true #, :validate => true
  belongs_to :checkin #, :validate => true
  belongs_to :librarian, :class_name => 'User' #, :validate => true
  belongs_to :basket #, :validate => true
  has_many :reminder_list

  validates_associated :user, :item, :librarian, :checkin #, :basket
  # TODO: 貸出履歴を保存しない場合は、ユーザ名を削除する
  #validates_presence_of :user, :item, :basket
  validates_presence_of :item_id, :basket_id, :due_date
  validates_uniqueness_of :item_id, :scope => [:basket_id, :user_id]
  validate :is_not_checked?, :on => :create
  validates_date :due_date

  paginates_per 10

  def day_of_overdue
    due_date_datetype = due_date.strftime("%Y-%m-%d")
    overdue = (Date.today - due_date_datetype.to_date) 
    overdue = 0 if overdue < 0
    return overdue
  end

  def is_not_checked?
    checkout = Checkout.not_returned.where(:item_id => self.item.id) rescue nil
    unless checkout.empty?
      errors[:base] << I18n.t('activerecord.errors.messages.checkin.already_checked_out')
    end
  end

  def checkout_renewable?
    return false if self.overdue?
    if self.item
      return false if self.over_checkout_renewal_limit?
      return false if self.reserved?
    end
    true
  end

  def reserved?
    return true if self.item.reserved?
  end

  def over_checkout_renewal_limit?
    return true if self.item.checkout_status(self.user).checkout_renewal_limit <= self.checkout_renewal_count
  end

  def overdue?
#    if Time.zone.now.tomorrow.beginning_of_day >= self.due_date
    if Time.zone.now.beginning_of_day > self.due_date
      return true
    else
      return false
    end
  end

  def is_today_due_date?
    if Time.zone.now.beginning_of_day == self.due_date.beginning_of_day
      return true
    else
      return false
    end
  end

  def set_renew_due_date(user)
    if self.item
      if self.checkout_renewal_count <= self.item.checkout_status(user).checkout_renewal_limit
        renew_due_date = self.due_date.advance(:days => self.item.checkout_status(user).checkout_period)
      else
        renew_due_date = self.due_date
      end
    end
  end

  def self.manifestations_count(start_date, end_date, manifestation)
    self.completed(start_date, end_date).where(:item_id => manifestation.items.collect(&:id)).count
  end

  def self.send_due_date_notification
    template = 'recall_item'
    queues = []
    User.find_each do |user|
      # 未来の日時を指定する
      checkouts = user.checkouts.due_date_on(user.user_group.number_of_day_to_notify_due_date.days.from_now.beginning_of_day)
      unless checkouts.empty?
        if SystemConfiguration.get("send_message.recall_item")
          queues << user.send_message(template, :manifestations => checkouts.collect(&:item).collect(&:manifestation))
        end
      end
    end
    queues.size
  end

  def self.send_overdue_notification
    template = 'recall_overdue_item'
    queues = []
    User.find_each do |user|
      user.user_group.number_of_time_to_notify_overdue.times do |i|
        checkouts = user.checkouts.due_date_on((user.user_group.number_of_day_to_notify_overdue * (i + 1)).days.ago.beginning_of_day)
        unless checkouts.empty?
          if SystemConfiguration.get("send_message.recall_overdue_item")
            queues << user.send_message(template, :manifestations => checkouts.collect(&:item).collect(&:manifestation))
          end
        end
      end
    end
    queues.size
  end

  def self.apend_to_reminder_list
    queues_size = 0 
    User.find_each do |user|
      user.user_group.number_of_time_to_notify_overdue.times do |i|
        checkouts = user.checkouts.due_date_on((user.user_group.number_of_day_to_notify_overdue * (i + 1)).days.ago.beginning_of_day)
        unless checkouts.empty?
          checkouts.each do |checkout|
            #logger.info checkout
            r = ReminderList.where(:checkout_id => checkout.id)
            unless r.nil?
              r = ReminderList.new
              r.checkout_id = checkout.id
              r.status = 0
              r.save!
              logger.info "create ReminderList checkout_id=#{checkout.id}"
              queues_size += 1
            end
          end
        end
      end
    end

    queues_size
  end

  # output
  def self.output_checkouts(checkouts, user, current_user)
    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'checkouts.tlf')

    report.layout.config.list(:list) do
      use_stores :total => 0
      events.on :footer_insert do |e|
        e.section.item(:total).value(checkouts.size)
        e.section.item(:message).value(SystemConfiguration.get("checkouts_print.message"))
      end
    end

    library = Library.find(current_user.library_id) rescue nil

    report.start_new_page do |page|
      page.item(:library).value(LibraryGroup.system_name(@locale))
      page.item(:user).value(user.user_number)
      page.item(:lend_user).value(current_user.user_number)
      page.item(:lend_library).value(library.display_name)
      page.item(:lend_library_telephone_number_1).value(library.telephone_number_1)
      page.item(:lend_library_telephone_number_2).value(library.telephone_number_2)
      page.item(:date).value(Time.now.strftime('%Y/%m/%d'))

      checkouts.each do |checkout|
        page.list(:list).add_row do |row|
          row.item(:book).value(checkout.item.manifestation.original_title)
          row.item(:due_date).value(checkout.due_date)
        end
      end
    end
    return report
  end

  def self.output_checkoutlist_pdf(checkouts, view)
    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'checkoutlist.tlf')

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
      if view == 'overdue'
        page.item(:page_title).value(I18n.t('checkout.listing_overdue_item'))
      else
        page.item(:page_title).value(I18n.t('page.listing', :model => I18n.t('activerecord.models.checkout')))
      end

      if checkouts.size == 0
        page.list(:list).add_row do |row|
          row.item(:not_found).show
          row.item(:not_found).value(I18n.t('page.no_record_found'))
          (1..7).each do |i|
            row.item("line#{i}").hide
          end
        end
      else
        checkouts.each do |checkout|
          page.list(:list).add_row do |row|
            row.item(:not_found).hide
            user = checkout.user.patron.full_name
            if SystemConfiguration.get("checkout_print.old") == true and checkout.user.patron.date_of_birth
              age = (Time.now.strftime("%Y%m%d").to_f - checkout.user.patron.date_of_birth.strftime("%Y%m%d").to_f) / 10000
              age = age.to_i
              user = user + '(' + age.to_s + I18n.t('activerecord.attributes.patron.old')  +')'
            end
            row.item(:user).value(user)
            row.item(:title).value(checkout.item.manifestation.original_title)
            row.item(:item_identifier).value(checkout.item.item_identifier)
            row.item(:library).value(checkout.item.shelf.library.display_name.localize)
            row.item(:shelf).value(checkout.item.shelf.display_name.localize)
            row.item(:due_date).value(checkout.due_date.strftime("%Y/%m/%d"))
            renewal_count = checkout.checkout_renewal_count.to_s + '/' + checkout.item.checkout_status(checkout.user).checkout_renewal_limit.to_s
            row.item(:renewal_count).value(renewal_count)
            due_date_datetype = checkout.due_date.strftime("%Y-%m-%d")
            overdue = Date.today - due_date_datetype.to_date
            overdue = 0 if overdue < 0
            row.item(:overdue).value(overdue)
          end
        end
      end
     end
    return report
  end

  def self.output_checkoutlist_csv(checkouts, view)
    data = String.new
    data << "\xEF\xBB\xBF".force_encoding("UTF-8") + "\n"
    columns = [
      [:user,'activerecord.models.user'],
      [:title, 'activerecord.attributes.manifestation.original_title'],
      [:item_identifier,'activerecord.attributes.item.item_identifier'],
      [:library, 'activerecord.models.library'],
      [:shelf, 'activerecord.models.shelf'],
      [:due_date, 'activerecord.attributes.checkout.due_date'],
      [:renewal_count, 'activerecord.attributes.checkout.renewal_count'],
      [:overdue, 'checkout.number_of_day_overdue'],
    ]

    # title column
    row = columns.map {|column| I18n.t(column[1])}
    data << '"'+row.join("\"\t\"")+"\"\n"

    # set
    checkouts.each do |checkout|
      row = []
      columns.each do |column|
        case column[0]
        when :user
          user = checkout.user.patron.full_name
          if SystemConfiguration.get("reserve_print.old") == true and  checkout.user.patron.date_of_birth
            age = (Time.now.strftime("%Y%m%d").to_f - checkout.user.patron.date_of_birth.strftime("%Y%m%d").to_f) / 10000
            age = age.to_i
            user = user + '(' + age.to_s + I18n.t('activerecord.attributes.patron.old')  +')'
          end
          row << user
        when :title
          row << checkout.item.manifestation.original_title 
        when :item_identifier
          row << checkout.item.item_identifier
        when :library
          row << checkout.item.shelf.library.display_name.localize
        when :shelf
          row << checkout.item.shelf.display_name.localize
        when :due_date
          row << checkout.due_date.strftime("%Y/%m/%d")
        when :renewal_count
          renewal_count = checkout.checkout_renewal_count.to_s + '/' + checkout.item.checkout_status(checkout.user).checkout_renewal_limit.to_s
          row << renewal_count
        when :overdue
          due_date_datetype = checkout.due_date.strftime("%Y-%m-%d")
          overdue = Date.today - due_date_datetype.to_date
          overdue = 0 if overdue < 0
          row << overdue
        end
      end
      data << '"'+row.join("\"\t\"")+"\"\n"
    end 
    return data
  end

  def self.get_checkoutlists_pdf(displist)
    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'circulation_status_list.tlf')

    # set page_num
    report.events.on :page_create do |e|
      e.page.item(:page).value(e.page.no)
    end
    report.events.on :generate do |e|
      e.pages.each do |page|
        page.item(:total).value(e.report.page_count)
      end
    end
    # set items
    report.start_new_page do |page|
      page.item(:date).value(Time.now)
      before_status = nil
      displist.each do |d|
        unless d.items.blank?
          d.items.each do |item|
            page.list(:list).add_row do |row|
              if before_status == d.circulation_status
               row.item(:status_line).hide
               row.item(:status).hide
              end
              row.item(:status).value(d.circulation_status)
              row.item(:title).value(item.manifestation.original_title)
              row.item(:library).value(item.shelf.library.display_name)
              row.item(:shelf).value(item.shelf.display_name.localize)
              row.item(:call_number).value(call_numberformat(item)) if item.call_number
              row.item(:identifier).value(item.item_identifier) if item.item_identifier
            end
            before_status = d.circulation_status
          end
        else
          page.list(:list).add_row do |row|
            row.item(:status).value(d.circulation_status)
            row.item(:title).value(I18n.t('page.no_record_found'))
            row.item(:line2).hide
            row.item(:line3).hide
            row.item(:line4).hide
            row.item(:line5).hide
          end
        end
      end
    end
    return report
  end

  def self.get_checkoutlists_tsv(displist)
    data = String.new
    data << "\xEF\xBB\xBF".force_encoding("UTF-8") + "\n"
    columns = [
      [:title,           'activerecord.attributes.manifestation.original_title'],
      [:library,         'activerecord.models.library'],
      [:shelf,           'activerecord.models.shelf'],
      [:call_number,     'activerecord.attributes.item.call_number'],
      [:item_identifier, 'activerecord.attributes.item.item_identifier'],
    ]

    displist.each do |d|
      data << '"'+d.circulation_status+"\"\n"
      row = columns.map { |column| I18n.t(column[1]) }
      data << '"'+row.join("\"\t\"")+"\"\n"
      d.items.each do |item|
        row = []
        columns.each do |column|
          case column[0]
          when :title
            row << item.manifestation.original_title 
          when :library
            row << item.shelf.library.display_name
          when :shelf
            row << item.shelf.display_name.localize
          when :call_number
            row << call_numberformat(item) if item.call_number
          when :item_identifier
            row << item.item_identifier if item.item_identifier
          end
        end
        data << '"'+row.join("\"\t\"")+"\"\n"
      end
      data << "\n"
    end
    return data
  end
end

# == Schema Information
#
# Table name: checkouts
#
#  id                     :integer         not null, primary key
#  user_id                :integer
#  item_id                :integer         not null
#  checkin_id             :integer
#  librarian_id           :integer
#  basket_id              :integer
#  due_date               :datetime
#  checkout_renewal_count :integer         default(0), not null
#  lock_version           :integer         default(0), not null
#  created_at             :datetime
#  updated_at             :datetime
#

