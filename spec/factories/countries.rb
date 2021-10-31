FactoryBot.define do
  factory :country do |f|
    f.sequence(:name){|n| "country_#{n}"}
    f.sequence(:alpha_2){|n| "alpha_2_#{n}"}
    f.sequence(:alpha_3){|n| "alpha_3_#{n}"}
    f.sequence(:numeric_3){|n| "numeric_3_#{n}"}
  end
end

# == Schema Information
#
# Table name: countries
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  display_name :text
#  alpha_2      :string
#  alpha_3      :string
#  numeric_3    :string
#  note         :text
#  position     :integer
#
