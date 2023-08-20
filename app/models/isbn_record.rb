class IsbnRecord < ApplicationRecord
  has_many :isbn_record_and_manifestations, dependent: :destroy
  has_many :manifestations, through: :isbn_record_and_manifestations
  before_save :normalize_isbn
  validates :body, presence: true
  strip_attributes

  def self.new_records(isbn_records_params)
    return [] unless isbn_records_params
    isbn_records = []
    IsbnRecord.transaction do
      isbn_records_params.each do |k, v|
        next if v['_destroy'] == '1'
        if v['body'].present?
          isbn_record = IsbnRecord.where(body: Lisbn.new(v['body'].gsub(/[^0-9x]/i, '')).isbn13).first_or_create!
        elsif v['id'].present?
          isbn_record = IsbnRecord.find(v['id'])
        else
          v.delete('_destroy')
          isbn_record = IsbnRecord.create(v)
        end
        isbn_records << isbn_record
      end
    end
    isbn_records
  end

  def normalize_isbn
    if StdNum::ISBN.valid?(body)
      self.body = StdNum::ISBN.normalize(body)
    else
      errors.add(:body)
    end
  end

  def valid_isbn?
    StdNum::ISBN.valid?(body)
  end
end

# == Schema Information
#
# Table name: isbn_records
#
#  id         :bigint           not null, primary key
#  body       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
