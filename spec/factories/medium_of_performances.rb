FactoryBot.define do
  factory :medium_of_performance do |f|
    f.sequence(:name){|n| "medium_of_performance_#{n}"}
  end
end

# == Schema Information
#
# Table name: medium_of_performances
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#
