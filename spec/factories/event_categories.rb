FactoryBot.define do
  factory :event_category do |f|
    f.sequence(:name){|n| "event_category_#{n}"}
  end
end

# == Schema Information
#
# Table name: event_categories
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
