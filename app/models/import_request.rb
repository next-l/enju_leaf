class ImportRequest < ActiveRecord::Base
  default_scope :order => 'id DESC'
  belongs_to :manifestation, :class_name => 'Resource'
  belongs_to :user
  validates_presence_of :isbn
  validate :check_isbn
  validate :check_imported, :on => :create
  enju_ndl

  state_machine :initial => :pending do
    event :sm_fail do
      transition :pending => :failed
    end

    event :sm_complete do
      transition :pending => :completed
    end
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
      sm_complete!
      manifestation.index!
    else
      sm_fail!
    end
  end
end
