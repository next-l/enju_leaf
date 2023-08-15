class ImportRequest < ApplicationRecord
  include Statesman::Adapters::ActiveRecordQueries[
    transition_class: ImportRequestTransition,
    initial_state: ImportRequestStateMachine.initial_state
  ]
  default_scope { order('import_requests.id DESC') }
  belongs_to :manifestation, optional: true
  belongs_to :user
  validates :isbn, presence: true
  validate :check_isbn
  #validate :check_imported, on: :create
  #validates_uniqueness_of :isbn, if: Proc.new{|request| ImportRequest.where("created_at > ?", 1.day.ago).collect(&:isbn).include?(request.isbn)}

  has_many :import_request_transitions, autosave: false, dependent: :destroy

  def state_machine
    ImportRequestStateMachine.new(self, transition_class: ImportRequestTransition)
  end

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
    to: :state_machine

  def check_isbn
    return if isbn.blank?

    errors.add(:isbn) unless StdNum::ISBN.valid?(isbn)
  end

  def check_imported
    if isbn.present?
      identifier_type = IdentifierType.find_by_or_create!(name: 'isbn')
      if Identifier.find_by(body: isbn, identifier_type_id: identifier_type.id)&.manifestation
        errors.add(:isbn, I18n.t('import_request.isbn_taken'))
      end
    end
  end

  def import!
    exceptions = [ActiveRecord::RecordInvalid, NameError, URI::InvalidURIError]
    not_found_exceptions = []
    not_found_exceptions << EnjuNdl::RecordNotFound if defined? EnjuNdl
    not_found_exceptions << EnjuNii::RecordNotFound if defined? EnjuNii
    not_found_exceptions << EnjuLoc::RecordNotFound if defined? EnjuLoc
    begin
      return nil unless Manifestation.respond_to?(:import_isbn)

      unless manifestation
        manifestation = Manifestation.import_isbn(isbn)
        if manifestation
          self.manifestation = manifestation
          transition_to!(:completed)
          manifestation.index
          Sunspot.commit
        else
          transition_to!(:failed)
        end
      end
      save
    rescue *not_found_exceptions => e
      transition_to!(:failed)
      "record_not_found"
    rescue *exceptions => e
      transition_to!(:failed)
      :error
    end
  end
end

# == Schema Information
#
# Table name: import_requests
#
#  id               :bigint           not null, primary key
#  isbn             :string
#  manifestation_id :bigint
#  user_id          :bigint
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
