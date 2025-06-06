class Identifier < ApplicationRecord
  belongs_to :identifier_type
  belongs_to :manifestation, touch: true, optional: true

  validates :body, presence: true
  validates :body, uniqueness: { scope: [ :identifier_type_id, :manifestation_id ] }
  validate :check_identifier
  before_validation :normalize
  before_save :convert_isbn
  scope :id_type, ->(type) {
    where(identifier_type: IdentifierType.find_by(name: type))
  }
  scope :not_migrated, -> {
    joins(:identifier_type).where.not(
      "identifier_types.name": [
        "isbn", "issn", "jpno", "ncid", "lccn", "doi", "iss_itemno"
      ]
    )
  }

  acts_as_list scope: :manifestation_id
  strip_attributes only: :body

  after_destroy do
    manifestation&.touch
  end

  def check_identifier
    case identifier_type.try(:name)
    when "isbn"
      unless StdNum::ISBN.valid?(body)
        errors.add(:body)
      end

    when "issn"
      unless StdNum::ISSN.valid?(body)
        errors.add(:body)
      end

    when "lccn"
      unless StdNum::LCCN.valid?(body)
        errors.add(:body)
      end

    when "doi"
      if URI.parse(body).scheme
        errors.add(:body)
      end
    end
  end

  def convert_isbn
    if identifier_type.name == "isbn"
      lisbn = Lisbn.new(body)
      if lisbn.isbn
        if lisbn.isbn.length == 10
          self.body = lisbn.isbn13
        end
      end
    end
  end

  def hyphenated_isbn
    if identifier_type.name == "isbn"
      lisbn = Lisbn.new(body)
      lisbn.parts.join("-")
    end
  end

  def normalize
    case identifier_type.try(:name)
    when "isbn"
      self.body = StdNum::ISBN.normalize(body)
    when "issn"
      self.body = StdNum::ISSN.normalize(body)
    when "lccn"
      self.body = StdNum::LCCN.normalize(body)
    end
  end
end

# == Schema Information
#
# Table name: identifiers
#
#  id                 :bigint           not null, primary key
#  body               :string           not null
#  position           :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  identifier_type_id :bigint           not null
#  manifestation_id   :bigint
#
# Indexes
#
#  index_identifiers_on_body_and_identifier_type_id  (body,identifier_type_id)
#  index_identifiers_on_manifestation_id             (manifestation_id)
#
