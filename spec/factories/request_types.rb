FactoryBot.define do
  factory :request_type do |f|
    f.sequence(:name) {|n| "request_type_#{n}"}
  end
end

# == Schema Information
#
# Table name: request_types
#
#  id           :bigint           not null, primary key
#  display_name :text
#  name         :string           not null
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_request_types_on_lower_name  (lower((name)::text)) UNIQUE
#
