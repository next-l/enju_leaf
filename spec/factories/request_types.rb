FactoryBot.define do
  factory :request_type do |f|
    f.sequence(:name){|n| "request_type_#{n}"}
  end
end

# == Schema Information
#
# Table name: request_types
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
