class ReminderList < ActiveRecord::Base
  attr_accessible :item_identifier, :status, :mail_sent_at

  default_scope :order => 'reminder_lists.id DESC'

  validates_presence_of :checkout_id, :status
  validates_uniqueness_of :checkout_id
  validate :check_checkout_id
  validate :check_due_date
  attr_accessor :item_identifier

  belongs_to :checkout

  before_validation :set_checkout_id, :on => :create

  paginates_per 10

  def self.statuses
    #TODO
    [{:id => 0, :display_name => I18n.t('activerecord.attributes.reminder_list.status_name.accepted')},
     {:id => 1, :display_name => I18n.t('activerecord.attributes.reminder_list.status_name.called')}
    ]
  end

  def check_checkout_id
    unless self.checkout_id.blank?
      checkout = Checkout.find(self.checkout_id)
      errors[:base] << I18n.t('checkout.no_checkout') unless checkout
    end
  end
   
  def check_due_date
    errors[:base] << I18n.t('activerecord.errors.messages.reminder_list.not_overdue') unless checkout.overdue?
  end

  def status_name
    case status
    when 0
      I18n.t('activerecord.attributes.reminder_list.status_name.accepted')
    when 1
      I18n.t('activerecord.attributes.reminder_list.status_name.called')
    end
  end

  searchable do
    integer :id
    integer :checkout_id 
    integer :status
    integer :library_id do
      checkout.try(:item).try(:shelf).try(:library_id)
    end
    time :created_at
    time :updated_at
    time :type1_printed_at
    time :type2_printed_at

    text :full_name do
      full_name = []
      full_name << self.checkout.user.patron.full_name if self.try(:checkout).try(:user).try(:patron)
      full_name << self.checkout.user.patron.full_name_transcription if self.try(:checkout).try(:user).try(:patron)
    end

    text :title do
      titles = []
      titles << self.try(:checkout).try(:item).try(:manifestation).try(:original_title)
      titles << self.try(:checkout).try(:item).try(:manifestation).try(:title_transcription)
    end
    boolean :checkin do
      true if checkout.try(:checkin_id)
    end
    time :due_date do
      checkout.try(:due_date)
    end
  end

  def set_checkout_id
    return if self.checkout_id
    checkout = Checkout.where(:item_id => Item.where(:item_identifier => self.item_identifier.strip).first.id).not_returned.order("created_at DESC").first rescue nil
    if checkout.nil?
      errors[:base] << I18n.t('activerecord.errors.messages.reminder_list.no_checkout')
      return false
    end
    self.checkout = checkout
  end

  def self.output_reminder_list_pdf(reminder_lists)
    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'reminder_list.tlf')

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
      if reminder_lists.size > 0
        reminder_lists.each do |reminder_list|
          page.list(:list).add_row do |row|
            row.item(:checkout_id).value(reminder_list.checkout.id)
            row.item(:title).value(reminder_list.checkout.item.manifestation.original_title)
            row.item(:call_number).value(reminder_list.checkout.try(:item).try(:call_number))
            row.item(:user).value(reminder_list.try(:checkout).try(:user).try(:patron).try(:full_name) + "(" + reminder_list.try(:checkout).try(:user_username) + ")") rescue nil
            row.item(:state).value(reminder_list.status_name)
            row.item(:due_date).value(reminder_list.checkout.due_date)
            row.item(:number_of_day_overdue).value(reminder_list.checkout.day_of_overdue)
            row.item(:library).value(reminder_list.checkout.item.shelf.library.display_name.localize)
          end
        end
      end
    end
    return report
  end

  def self.output_reminder_list_tsv(reminder_lists)
    columns = [
      [:checkout_id, 'activerecord.attributes.reminder_list.checkout_id'],
      [:title, 'activerecord.attributes.reminder_list.original_title'],
      [:call_number, 'activerecord.attributes.item.call_number'],
      [:user, 'activerecord.attributes.reminder_list.user_name'],
      [:state, 'activerecord.attributes.reminder_list.status'],
      [:due_date, 'activerecord.attributes.reminder_list.due_date'],
      [:number_of_day_overdue, 'activerecord.attributes.reminder_list.number_of_day_overdue'],
      [:library, 'activerecord.attributes.reminder_list.library'],
    ]

    data = String.new
      # title column
      row = []
      columns.each do |column|
        row << I18n.t(column[1])
      end
      data <<  '"'+row.join("\"\t\"")+"\"\n"

      # set
      reminder_lists.each do |reminder_list|
        row = []
        columns.each do |column|
          case column[0]
          when :checkout_id
            row << reminder_list.checkout.id || "" rescue ""
          when :title
            row << reminder_list.try(:checkout).try(:item).try(:manifestation).try(:original_title) || "" rescue ""
          when :call_number
            row << reminder_list.try(:checkout).try(:item).try(:call_number) || "" rescue ""
          when :user
            row << (reminder_list.try(:checkout).try(:user).try(:patron).try(:full_name) + "(" + reminder_list.try(:checkout).try(:user_username) + ")" || "" rescue "")
          when :state
            row << reminder_list.try(:status_name) || "" rescue ""
          when :due_date 
            row << reminder_list.try(:checkout).try(:due_date) || "" rescue ""
          when :number_of_day_overdue
            row << reminder_list.try(:checkout).try(:day_of_overdue) || "" rescue ""
          when :library
            row << reminder_list.try(:checkout).try(:item).try(:shelf).try(:library).try(:display_name).try(:localize) || "" rescue ""
          end
        end
        data << '"'+row.join("\"\t\"")+"\"\n"
      end
    return data
  end

  def self.output_reminder_postal_card(file, reminder_lists, user, current_user)
    logger.info "create_file=> #{file}"

    report = ThinReports::Report.create do
      use_layout File.join(Rails.root, 'report', 'reminder_postal_card_back.tlf'), :default => true
      #report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'reminder_postal_card_front.tlf')
      # address
      #report.start_new_page do |page|
      start_new_page :layout => File.join(Rails.root, 'report', 'reminder_postal_card_front.tlf') do |page|
        max_column = 16
        page.item(:zip_code).value(user.patron.zip_code_1) if user.patron.zip_code_1
        if user.patron.address_1
          address = user.patron.address_1
          cnt, str_num = 0.0, 0
          while address.length > max_column
            address.length.times { |i|
              cnt += 0.5 if address[i] =~ /^[\s0-9A-Za-z]+$/
              cnt += 1 unless address[i] =~ /^[\s0-9A-Za-z]+$/
              if cnt.to_f >= max_column or address[i+1].nil? or address[i] =~ /^[\n]+$/
                str_num = i + 1 if cnt.to_f == max_column or address[i+1].nil? or address[i] =~ /^[\n]+$/
                str_num = i if cnt.to_f > max_column #or address[i] =~ /^[\n]+$/
                page.list(:list).add_row do |row|
                  row.item(:address).value(address[0...str_num].chomp)
                end
                address = address[str_num...address.length]
                cnt, str_num = 0.0, 0
                break
              end
            }
          end
          page.list(:list).add_row do |row|
            row.item(:address).value(address)
          end
        end
        # space
        page.list(:list).add_row
        # name
        name = user.patron.full_name
        cnt, str_num = 0.0, 0
        while name.length > max_column
          name.length.times { |i|
            cnt += 0.5 if name[i] =~ /^[\s0-9A-Za-z]+$/
            cnt += 1 unless name[i] =~ /^[\s0-9A-Za-z]+$/
            if cnt.to_f >= max_column or name[i+1].nil? or name[i] =~ /^[\n]+$/
              str_num = i + 1 if cnt.to_f == max_column or name[i+1].nil? or name[i] =~ /^[\n]+$/
              str_num = i if cnt.to_f > max_column #or name[i] =~ /^[\n]+$/
              page.list(:list).add_row do |row|
                row.item(:address).value(name[0...str_num].chomp)
              end
              name = name[str_num...name.length]
              cnt, str_num = 0.0, 0
              break
            end
          }
        end
        page.list(:list).add_row do |row|
          row.item(:address).value(name + " " + I18n.t('activerecord.attributes.reminder_list.honorific1'))
        end
      end    

      # detail
      start_new_page do |page|
        page.item(:date).value(Time.now)
        page.item(:user_number).value(user.user_number) if user.user_number
        page.item(:user).value(user.patron.full_name + " " + I18n.t('activerecord.attributes.reminder_list.honorific2')) if user.patron.full_name
        page.item(:message).value(SystemConfiguration.get("reminder_postal_card_message"))
        page.item(:library).value(LibraryGroup.system_name(@locale))
        library = Library.find(current_user.library_id) rescue nil
        page.item(:current_user_library).value(library.display_name.localize) if library
        page.item(:telephone_number).value(library.telephone_number_1) if library.telephone_number_1
        page.item(:address).value(library.address) if library.address
        # list
        cnt = 0
        length = max_length = 5
        length = reminder_lists.size if reminder_lists.size < 5
        (0...length).each do |i|
          reminder_list = reminder_lists[i]
          page.list(:list).add_row do |row|
            row.item(:item_identifier).value(reminder_list.checkout.item.item_identifier) if reminder_list.checkout.item.item_identifier
            row.item(:title).value(reminder_list.checkout.item.manifestation.original_title) if reminder_list.checkout.item.manifestation.original_title
            row.item(:due_date).value(reminder_list.checkout.due_date) if reminder_list.checkout.due_date
          end
        end
        page.list(:list).add_row do |row|
          row.item(:fence).hide
          row.item(:line0).hide
          row.item(:line1).hide
          row.item(:item_identifier).hide
          row.item(:title).hide
          row.item(:due_date).hide
          row.item(:items_num).show
          if reminder_lists.size > max_length
            row.item(:items_num).value(I18n.t('activerecord.attributes.reminder_list.other') + " " + (reminder_lists.size.to_i - max_length).to_s + " " + I18n.t('activerecord.attributes.reminder_list.items'))
          else
            row.item(:items_num).value(I18n.t('activerecord.attributes.reminder_list.total') + " " + reminder_lists.size.to_s + " " + I18n.t('activerecord.attributes.reminder_list.items'))
          end
        end       
      end
    end
    report.generate_file(file) 
  end

  def self.output_reminder_letter(file, reminder_lists, user, current_user)
    logger.info "create_file=> #{file}"

    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'reminder_letter.tlf')
    report.layout.config.list(:list) do
      events.on :footer_insert do |e|
        e.section.item(:items_num).value(I18n.t('activerecord.attributes.reminder_list.total') + " " + reminder_lists.size.to_s + " " + I18n.t('activerecord.attributes.reminder_list.items'))
      end
    end

    report.start_new_page do |page|
      page.item(:date).value(Time.now)
      page.item(:user_number).value(user.user_number) if user.user_number
      page.item(:user).value(user.patron.full_name + " " + I18n.t('activerecord.attributes.reminder_list.honorific2')) if user.patron.full_name
      page.item(:message).value(SystemConfiguration.get("reminder_letter_message"))
      page.item(:library).value(LibraryGroup.system_name(@locale))
      library = Library.find(current_user.library_id) rescue nil
      page.item(:current_user_library).value(library.display_name.localize) if library
      page.item(:telephone_number).value(library.telephone_number_1) if library.telephone_number_1
      page.item(:address).value(library.address) if library.address

      reminder_lists.each do |reminder_list|
        page.list(:list).add_row do |row|
          row.item(:item_identifier).value(reminder_list.checkout.item.item_identifier) if reminder_list.checkout.item.item_identifier
          row.item(:title).value(reminder_list.checkout.item.manifestation.original_title) if reminder_list.checkout.item.manifestation.original_title
          row.item(:due_date).value(reminder_list.checkout.due_date) if reminder_list.checkout.due_date
        end
      end
    end
    report.generate_file(file) 
  end
end
