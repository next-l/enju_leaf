class ImportRequest < ActiveRecord::Base
  attr_accessible :isbn, :manifestation_id, :user_id

  default_scope :order => 'id DESC'
  belongs_to :manifestation
  belongs_to :user
  validates_presence_of :isbn
  validate :check_isbn
  #validate :check_imported, :on => :create
  #validates_uniqueness_of :isbn, :if => Proc.new{|request| ImportRequest.where("created_at > ?", 1.day.ago).collect(&:isbn).include?(request.isbn)}

  enju_ndl_search

  state_machine :initial => :pending do
    event :sm_fail do
      transition :pending => :failed
    end

    event :sm_complete do
      transition :pending => :completed
    end
  end

  paginates_per 10

  def check_isbn
    if isbn.present?
      errors.add(:isbn) unless Lisbn.new(isbn).valid?
    end
  end

  def check_imported
    if isbn.present?
      if Manifestation.where(:isbn => isbn).first
        errors.add(:isbn, I18n.t('import_request.isbn_taken'))
      end
    end
  end

  def import!
    logger.info "import start"
    unless manifestation
      manifestation = self.class.import_isbn!(isbn)
      if manifestation
        self.manifestation = manifestation
        manifestation.update_attributes(:external_catalog => 1)
        sm_complete!
        manifestation.index!
      else
        sm_fail!
      end
    else
      sm_fail!
    end
  rescue ActiveRecord::RecordInvalid
    logger.info "manifestation import trap-94 fail"
    logger.info  $!
    logger.info  $@
    sm_fail!
  rescue EnjuNdl::RecordNotFound
    logger.info "manifestation import trap-96 fail"
    logger.info  $!
    logger.info  $@
    sm_fail!
  end
end

# == Schema Information
#
# Table name: import_requests
#
#  id               :integer         not null, primary key
#  isbn             :string(255)
#  state            :string(255)
#  manifestation_id :integer
#  user_id          :integer
#  created_at       :datetime
#  updated_at       :datetime
#

