FactoryBot.define do
  factory :classification_type do |f|
    f.sequence(:name){|n| "classification_type_#{n}"}
  end
end

# == Schema Information
#
# Table name: classification_types
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#
