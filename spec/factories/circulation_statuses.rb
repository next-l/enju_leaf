FactoryBot.define do
  factory :circulation_status do |f|
    f.sequence(:name){|n| "circulation_status_#{n}"}
  end
end

# == Schema Information
#
# Table name: circulation_statuses
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#
