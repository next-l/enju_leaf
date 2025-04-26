FactoryBot.define do
  factory :use_restriction do |f|
    f.sequence(:name) {|n| "use_restriction_#{n}"}
  end
end

# == Schema Information
#
# Table name: use_restrictions
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
#  index_use_restrictions_on_lower_name  (lower((name)::text)) UNIQUE
#
