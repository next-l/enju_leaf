class InterLibraryLoan < ActiveRecord::Base
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

  def self.per_page
    10
  end

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

  def do_request
    InterLibraryLoan.transaction do
      self.item.update_attributes({:circulation_status => CirculationStatus.where(:name => 'Recalled').first})
      self.update_attributes({:requested_at => Time.zone.now})
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
    self.sm_request! if self.save
  end

  def request_for_checkin(item, from_library)
    self.update_attributes(:item_id => item.id, :from_library_id => from_library.id, :to_library_id => item.shelf.library.id, :requested_at => Time.zone.now, :reason => 2)
    self.save
#    InterLibraryLoan.transaction do
#      item.update_attributes({:circulation_status => CirculationStatus.where(:name => 'Recalled').first})
#      self.update_attributes({:requested_at => Time.zone.now})
      self.sm_request! if self.save
#    end
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

