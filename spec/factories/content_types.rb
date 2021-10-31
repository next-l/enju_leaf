FactoryBot.define do
  factory :content_type do |f|
    f.sequence(:name){|n| "content_type_#{n}"}
  end
end

# == Schema Information
#
# Table name: content_types
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#
