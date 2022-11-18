FactoryBot.define do
  factory :subject_heading_type do |f|
    f.sequence(:name){|n| "subject_heading_type_#{n}"}
  end
end

# == Schema Information
#
# Table name: subject_heading_types
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
