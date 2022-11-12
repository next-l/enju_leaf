FactoryBot.define do
  factory :use_restriction do |f|
    f.sequence(:name){|n| "use_restriction_#{n}"}
  end
end

# == Schema Information
#
# Table name: use_restrictions
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
