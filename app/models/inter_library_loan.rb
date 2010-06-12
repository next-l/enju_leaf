class InterLibraryLoan < ActiveRecord::Base
  include AASM
  scope :completed, :conditions => {:state => 'return_received'}
  #scope :processing, lambda {|item, borrowing_library| {:conditions => ['item_id = ? AND borrowing_library_id = ? AND state != ?', item.id, borrowing_library.id, 'return_received']}}
  scope :processing, lambda {|item, borrowing_library| {:conditions => ['item_id = ? AND borrowing_library_id = ?', item.id, borrowing_library.id]}}

  belongs_to :item, :validate => true
  #belongs_to :reserve
  belongs_to :borrowing_library, :foreign_key => 'borrowing_library_id', :class_name => 'Library', :validate => true

  validates_presence_of :item_id, :borrowing_library_id
  validates_associated :item, :borrowing_library
  validate :check_library, :on => :create

  def check_library
    if self.item and self.borrowing_library
      unless InterLibraryLoan.processing(self.item, self.borrowing_library).blank?
        errors.add(:borrowing_library)
        errors.add(:item_identifier)
      end
    end
  end

  #acts_as_soft_deletable

  def self.per_page
    10
  end
  attr_accessor :item_identifier

  aasm_initial_state :pending

  aasm_column :state
  aasm_state :pending
  aasm_state :requested
  aasm_state :shipped
  aasm_state :received
  aasm_state :return_shipped
  aasm_state :return_received

  aasm_event :aasm_request do
    transitions :from => :pending, :to => :requested,
      :on_transition => :do_request
  end
  aasm_event :aasm_ship do
    transitions :from => :requested, :to => :shipped,
      :on_transition => :ship
  end

  aasm_event :aasm_receive do
    transitions :from => :shipped, :to => :received,
      :on_transition => :receive
  end

  aasm_event :aasm_return_ship do
    transitions :from => :received, :to => :return_shipped,
      :on_transition => :return_ship
  end

  aasm_event :aasm_return_receive do
    transitions :from => :return_shipped, :to => :return_received,
      :on_transition => :return_receive
  end

  def do_request
    InterLibraryLoan.transaction do
      self.item.update_attributes({:circulation_status => CirculationStatus.first(:conditions => {:name => 'Recalled'})})
      self.update_attributes({:requested_at => Time.zone.now})
    end
  end

  def ship
    InterLibraryLoan.transaction do
      self.item.update_attributes({:circulation_status => CirculationStatus.first(:conditions => {:name => 'In Transit Between Library Locations'})})
      self.update_attributes({:shipped_at => Time.zone.now})
    end
  end

  def receive
    InterLibraryLoan.transaction do
      self.item.update_attributes({:circulation_status => CirculationStatus.first(:conditions => {:name => 'In Process'})})
      self.update_attributes({:received_at => Time.zone.now})
    end
  end

  def return_ship
    InterLibraryLoan.transaction do
      self.item.update_attributes({:circulation_status => CirculationStatus.first(:conditions => {:name => 'In Transit Between Library Locations'})})
      self.update_attributes({:return_shipped_at => Time.zone.now})
    end
  end

  def return_receive
    InterLibraryLoan.transaction do
      # TODO: 'Waiting To Be Reshelved'
      self.item.update_attributes({:circulation_status => CirculationStatus.first(:conditions => {:name => 'Available On Shelf'})})
      self.update_attributes({:return_received_at => Time.zone.now})
    end
  end
end
