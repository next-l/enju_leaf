class ImportRequest < ActiveRecord::Base
  include AASM
  belongs_to :user
  belongs_to :manifestation, :class_name => 'Resource'
  validates_presence_of :isbn
  validate :check_isbn
  validate :check_imported, :on => :create
  enju_ndl

  aasm_column :state
  aasm_state :pending
  aasm_state :failed
  aasm_state :completed
  aasm_initial_state :pending

  aasm_event :aasm_fail do
    transitions :from => :pending, :to => :failed
  end

  aasm_event :aasm_complete do
    transitions :from => :pending, :to => :completed
  end

  def check_isbn
    if isbn.present?
      errors.add(:isbn) unless ISBN_Tools.is_valid?(isbn)
    end
  end

  def check_imported
    if isbn.present?
      errors.add(:isbn) if Resource.first(:conditions => {:isbn => isbn})
    end
  end

  def self.import_patrons(patron_lists)
    patrons = []
    patron_lists.each do |patron_list|
      unless patron = Patron.first(:conditions => {:full_name => patron_list})
        patron = Patron.new(:full_name => patron_list) #, :language_id => 1)
        #patron.required_role = Role.first(:conditions => {:name => 'Guest'})
      end
      patron.save
      patrons << patron
    end
    patrons
  end

  def import!
    unless manifestation
      manifestation = self.class.import_isbn!(isbn)
      self.manifestation = manifestation
      aasm_complete!
      manifestation.index!
    else
      aasm_fail!
    end
  end

end
