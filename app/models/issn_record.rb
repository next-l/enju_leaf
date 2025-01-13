class IssnRecord < ApplicationRecord
  has_many :issn_record_and_manifestations, dependent: :destroy
  has_many :manifestations, through: :issn_record_and_manifestations
  validates :body, presence: true, uniqueness: true
  before_save :normalize_issn
  strip_attributes

  def normalize_issn
    if StdNum::ISSN.valid?(body)
      self.body = StdNum::ISSN.normalize(body)
    else
      errors.add(:body)
    end
  end

  def self.new_records(issn_records_params)
    return [] unless issn_records_params

    issn_records = []
    IssnRecord.transaction do
      issn_records_params.each do |k, v|
        next if v['_destroy'] == '1'
        if v['body'].present?
          issn_record = IssnRecord.where(body: v['body'].gsub(/[^0-9x]/i, '')).first_or_create!
        elsif v['id'].present?
          issn_record = IssnRecord.find(v['id'])
        else
          v.delete('_destroy')
          issn_record = IssnRecord.create(v)
        end
        issn_records << issn_record
      end
    end
    issn_records
  end
end

# == Schema Information
#
# Table name: issn_records
#
#  id         :bigint           not null, primary key
#  body       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
