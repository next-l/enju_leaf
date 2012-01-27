class ReminderList < ActiveRecord::Base
  default_scope :order => 'reminder_lists.id DESC'

  validates_presence_of :checkout_id, :status
  validate :check_checkout_id

  belongs_to :checkout

  def self.per_page
    10
  end

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
    time :created_at
    time :updated_at
    time :type1_printed_at
    time :type2_printed_at

    text :full_name do
      full_name = []
      full_name << self.checkout.user.patron.full_name if self.checkout.user.patron 
      full_name << self.checkout.user.patron.full_name_transcription if self.checkout.user.patron
    end

    text :title do
      titles = []
      titles << self.checkout.item.manifestation.original_title
      titles << self.checkout.item.manifestation.title_transcription
    end
  end

  def self.output_reminder_postal_card(file, reminder_lists, user, current_user)
    logger.info "create_file=> #{file}"
    max_column = 16

    require 'thinreports'
    report = ThinReports::Report.create do
      use_layout File.join(Rails.root, 'report', 'reminder_postal_card_back.tlf'), :default => true
      #report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'reminder_postal_card_front.tlf')
      # address
      #report.start_new_page do |page|
      start_new_page :layout => File.join(Rails.root, 'report', 'reminder_postal_card_front.tlf') do |page|
        page.item(:zip_code).value(user.patron.zip_code_1) if user.patron.zip_code_1
        if user.patron.address_1
          address = user.patron.address_1
          cnt, str_num = 0.0, 0
          while address.length > max_column
            address.length.times { |i|
              cnt += 0.5 if address[i] =~ /^[\s0-9A-Za-z]+$/
              cnt += 1 unless address[i] =~ /^[\s0-9A-Za-z]+$/
              if cnt.to_f == max_column or cnt.to_f > max_column or address[i+1].nil? or address[i] =~ /^[\n]+$/
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
            if cnt.to_f == max_column or cnt.to_f > max_column or name[i+1].nil? or name[i] =~ /^[\n]+$/
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

     #report.layout.config.list(:list) do
=begin
      config.list(:list) do
        events.on :footer_insert do |e|
          if reminder_lists.size > 5
            e.section.item(:items_num).value(I18n.t('activerecord.attributes.reminder_list.other') + " " + (reminder_lists.size.to_i - 5).to_s + " " + I18n.t('activerecord.attributes.reminder_list.items'))
          else
            e.section.item(:items_num).value(I18n.t('activerecord.attributes.reminder_list.total')+ " " + reminder_lists.size.to_s + " " + I18n.t('activerecord.attributes.reminder_list.items'))
          end
        end
      end
=end
      # detail
      start_new_page do |page|
        page.item(:date).value(Time.now)
        page.item(:user_number).value(user.user_number) if user.user_number
        page.item(:user).value(user.patron.full_name + " " + I18n.t('activerecord.attributes.reminder_list.honorific2')) if user.patron.full_name
        page.item(:message).value(configatron.reminder_postal_card_message)
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
            row.item(:items_num).value(I18n.t('activerecord.attributes.reminder_list.total')+ " " + reminder_lists.size.to_s + " " + I18n.t('activerecord.attributes.reminder_list.items'))
          end
        end       
      end
    end
    report.generate_file(file) 
  end
end
