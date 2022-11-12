FactoryBot.define do
  factory :frequency do |f|
    f.sequence(:name){|n| "frequency_#{n}"}
  end
end

# == Schema Information
#
# Table name: frequencies
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
