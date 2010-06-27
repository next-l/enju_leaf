class InterLibraryLoan < ActiveRecord::Base
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
