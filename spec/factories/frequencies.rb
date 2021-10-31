FactoryBot.define do
  factory :frequency do |f|
    f.sequence(:name){|n| "frequency_#{n}"}
  end
end

# == Schema Information
#
# Table name: frequencies
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#
