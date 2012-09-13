class InterLibraryLoan < ActiveRecord::Base
  self.extend ItemsHelper
  default_scope :order => "created_at DESC"
  scope :completed, where(:state => 'return_received')
  #scope :processing, lambda {|item, to_library| {:conditions => ['item_id = ? AND to_library_id = ? AND state != ?', item.id, wto_library.id, 'return_received']}}
  scope :processing, lambda {|item, to_library| {:conditions => ['item_id = ? AND to_library_id = ?', item.id, to_library.id]}}
  scope :in_process, :order => "created_at ASC"

  belongs_to :item, :validate => true
  #belongs_to :reserve
  belongs_to :to_library, :foreign_key => 'to_library_id', :class_name => 'Library', :validate => true
  belongs_to :from_library, :foreign_key => 'from_library_id', :class_name => 'Library', :validate => true

  validates_presence_of :item_id, :from_library_id, :to_library_id
  validates_associated :item, :from_library, :to_library

  paginates_per 10

  attr_accessor :item_identifier

  state_machine :initial => :pending do
    before_transition :pending => :requested, :do => :do_request
    before_transition :requested => :shipped, :do => :ship
    before_transition :shipped => :received, :do => :receive
    before_transition :received => :return_shipped, :do => :return_ship
    before_transition :return_shipped => :return_received, :do => :return_receive

    event :sm_request do
      transition :pending => :requested
    end

    event :sm_ship do
      transition :requested => :shipped
    end

    event :sm_receive do
      transition :shipped => :received
    end

    event :sm_return_ship do
      transition :received => :return_shipped
    end

    event :sm_return_receive do
      transition :return_shipped => :return_received
    end
  end

  searchable do
    text :item_identifier do
      self.item.item_identifier if self.item
    end
    text :title do
      titles = []
      titles << self.item.manifestation.original_title if self.item
      titles << self.item.manifestation.title_transcription if self.item
    end
    string :state 
    integer :item_id
    integer :to_library_id
    integer :from_library_id
    integer :reason
    time :requested_at
    time :shipped_at
    time :received_at
    time :return_shipped_at
    time :return_received_at
    time :created_at
    time :updated_at
  end

  def do_request
    InterLibraryLoan.transaction do
      self.item.update_attribute(:circulation_status, CirculationStatus.where(:name => 'Recalled').first)
      self.update_attribute(:requested_at, Time.zone.now)
    end
  end

  def ship
    InterLibraryLoan.transaction do
      self.item.update_attributes({:circulation_status => CirculationStatus.where(:name => 'In Transit Between Library Locations').first})
      self.update_attributes({:shipped_at => Time.zone.now})
    end
  end

  def receive
    InterLibraryLoan.transaction do
#      self.item.update_attributes({:circulation_status => CirculationStatus.where(:name => 'In Process').first})
      self.update_attributes({:received_at => Time.zone.now})
    end
  end

  def return_ship
    InterLibraryLoan.transaction do
      self.item.update_attributes({:circulation_status => CirculationStatus.where(:name => 'In Transit Between Library Locations').first})
      self.update_attributes({:return_shipped_at => Time.zone.now})
    end
  end

  def return_receive
    InterLibraryLoan.transaction do
      # TODO: 'Waiting To Be Reshelved'
      self.item.update_attributes({:circulation_status => CirculationStatus.where(:name => 'Available On Shelf').first})
      self.update_attributes({:return_received_at => Time.zone.now})
    end
  end

  def request_for_reserve(item, to_library)
    self.update_attributes(:item_id => item.id, :to_library_id => to_library.id, :from_library_id => item.shelf.library.id, :requested_at => Time.zone.now, :reason => 1)
    self.sm_request!
  end

  def request_for_checkin(item, from_library)
    self.update_attributes(:item_id => item.id, :from_library_id => from_library.id, :to_library_id => item.shelf.library.id, :requested_at => Time.zone.now, :reason => 2)
    self.sm_request!
  end

  def self.loan_items
    loans = []
    item_ids = InterLibraryLoan.select(:item_id).where(:received_at => nil).inject([]){|ids, loan| ids << loan.item_id}.uniq
    item_ids.each do |id|
      loans << InterLibraryLoan.where(:item_id => id, :received_at => nil).order("reason DESC, created_at ASC").first
    end  
    return loans
  end

  def self.reasons
    reasons = [[I18n.t('inter_library_loan.checkout'), 1],
                [I18n.t('inter_library_loan.checkin'), 2]]
    return reasons
  end

  def self.get_loan_report(inter_library_loan)
    @loan = inter_library_loan
    begin
      report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/inter_library_loans/move_item"
      report.start_new_page
      report.page.item(:export_date).value(Time.now)
      report.page.item(:title).value(@loan.item.manifestation.original_title)
      report.page.item(:call_number).value(call_numberformat(@loan.item))
      report.page.item(:from_library).value(@loan.from_library.display_name.localize)
      report.page.item(:to_library).value(@loan.to_library.display_name.localize)
      report.page.item(:reason).value(I18n.t('inter_library_loan.checkout')) if @loan.reason == 1
      report.page.item(:reason).value(I18n.t('inter_library_loan.checkin')) if @loan.reason == 2
      reserve = Reserve.waiting.where(:item_id => @loan.item_id, :receipt_library_id => @loan.to_library_id, :state => 'in_process').first
      if reserve
        report.page.item(:user_title).show
        report.page.item(:reserve_user).value(reserve.user.username) if reserve.user
        report.page.item(:expire_date_title).show
        report.page.item(:reserve_expire_date).value(reserve.expired_at)
      end
      logger.error "created report: #{Time.now}"
      return report.generate
    rescue Exception => e
      logger.error "failed #{e}"
      return false
    end
  end

  def self.get_loan_lists(loans, library_ids)
    report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/inter_library_loans/loan_list"

    report.events.on :page_create do |e|
      e.page.item(:page).value(e.page.no)
    end
    report.events.on :generate do |e|
      e.pages.each do |page|
        page.item(:total).value(e.report.page_count)
      end
    end

    library_ids.each do |library_id|
      library = Library.find(library_id) rescue nil
      to_libraries = InterLibraryLoan.where(:from_library_id => library_id).inject([]){|libraries, data| libraries << Library.find(data.to_library_id)}
      next if to_libraries.blank?
      to_libraries.uniq.each do |to_library|
        report.start_new_page
        report.page.item(:date).value(Time.now)
        report.page.item(:library).value(library.display_name.localize)
        report.page.item(:library_move_to).value(to_library.display_name.localize)
        loans.each do |loan|
          if loan.from_library_id == library.id && loan.to_library_id == to_library.id && loan.reason == 1
            report.page.list(:list).add_row do |row|
              row.item(:reason).value(I18n.t('inter_library_loan.checkout'))
              row.item(:item_identifier).value(loan.item.item_identifier)
              row.item(:shelf).value(loan.item.shelf.display_name) if loan.item.shelf
              row.item(:call_number).value(call_numberformat(loan.item))
              row.item(:title).value(loan.item.manifestation.original_title) if loan.item.manifestation
            end
          end
        end
        loans.each do |loan|
          if loan.from_library_id == library.id && loan.to_library_id == to_library.id && loan.reason == 2
            report.page.list(:list).add_row do |row|
              row.item(:reason).value(I18n.t('inter_library_loan.checkin'))
              row.item(:item_identifier).value(loan.item.item_identifier)
              row.item(:shelf).value(loan.item.shelf.display_name) if loan.item.shelf
              row.item(:call_number).value(call_numberformat(loan.item))
              row.item(:title).value(loan.item.manifestation.original_title) if loan.item.manifestation
            end
          end
        end
      end
    end
    logger.error report.page
    return report
  end

  def self.get_pickup_item_file(pickup_item, loan)
    report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/inter_library_loans/move_item"
    report.start_new_page
    report.page.item(:export_date).value(Time.now)
    report.page.item(:title).value(pickup_item.manifestation.original_title)
    report.page.item(:call_number).value(call_numberformat(pickup_item))
    report.page.item(:from_library).value(loan.from_library.display_name.localize)
    report.page.item(:to_library).value(loan.to_library.display_name.localize)
    report.page.item(:reason).value(I18n.t('inter_library_loan.checkout')) if loan.reason == 1
    report.page.item(:reason).value(I18n.t('inter_library_loan.checkin')) if loan.reason == 2
    reserve = Reserve.waiting.where(:item_id => loan.item_id, :receipt_library_id => loan.to_library_id, :state => 'in_process').first
    if reserve
      report.page.item(:user_title).show
      report.page.item(:reserve_user).value(reserve.user.username) if reserve.user
      report.page.item(:expire_date_title).show
      report.page.item(:reserve_expire_date).value(reserve.expired_at)
    end
    return report
  end
end

# == Schema Information
#
# Table name: inter_library_loans
#
#  id                   :integer         not null, primary key
#  item_id              :integer         not null
#  to_library_id        :integer         not null
#  requested_at         :datetime
#  shipped_at           :datetime
#  received_at          :datetime
#  return_shipped_at    :datetime
#  return_received_at   :datetime
#  deleted_at           :datetime
#  state                :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  from_library_id        :integer         not null
#

