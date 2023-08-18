FactoryBot.define do
  factory :place do |f|
    f.sequence(:term){|n| "term_#{n}"}
  end
end

# == Schema Information
#
# Table name: places
#
#  id         :bigint           not null, primary key
#  term       :string
#  city       :text
#  country_id :bigint
#  latitude   :float
#  longitude  :float
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
