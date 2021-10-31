FactoryBot.define do
  factory :bookstore do |f|
    f.sequence(:name){|n| "bookstore_#{n}"}
  end
end

# == Schema Information
#
# Table name: bookstores
#
#  id               :integer          not null, primary key
#  name             :text             not null
#  zip_code         :string
#  address          :text
#  note             :text
#  telephone_number :string
#  fax_number       :string
#  url              :string
#  position         :integer
#  deleted_at       :datetime
#  created_at       :datetime
#  updated_at       :datetime
#
