FactoryBot.define do
  factory :bookstore do |f|
    f.sequence(:name){|n| "bookstore_#{n}"}
  end
end

# == Schema Information
#
# Table name: bookstores
#
#  id               :bigint           not null, primary key
#  name             :text             not null
#  zip_code         :string
#  address          :text
#  note             :text
#  telephone_number :string
#  fax_number       :string
#  url              :string
#  position         :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
