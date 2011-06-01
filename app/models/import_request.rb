class ImportRequest < ActiveRecord::Base
  default_scope :order => 'id DESC'
  belongs_to :manifestation, :class_name => 'Manifestation'
  belongs_to :user
  validates_presence_of :isbn
  validate :check_isbn
  validate :check_imported, :on => :create
  validates_uniqueness_of :isbn, :if => Proc.new{|request| ImportRequest.where("created_at > ?", 1.day.ago).collect(&:isbn).include?(request.isbn)}
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
      if Manifestation.first(:conditions => {:isbn => isbn})
        errors.add(:isbn, I18n.t('import_request.isbn_taken'))
      end
    end
  end

  def import!
    unless manifestation
      manifestation = self.class.import_isbn!(isbn)
      if manifestation
        self.manifestation = manifestation
        sm_complete!
        manifestation.index!
      else
        sm_fail!
      end
    else
      sm_fail!
    end
  rescue ActiveRecord::RecordInvalid
    sm_fail!
  rescue EnjuNdl::RecordNotFound
    sm_fail!
  end
end
