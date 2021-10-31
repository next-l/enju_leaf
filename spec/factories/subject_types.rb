FactoryBot.define do
  factory :subject_type do |f|
    f.sequence(:name){|n| "subject_type_#{n}"}
  end
end

# == Schema Information
#
# Table name: subject_types
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#
