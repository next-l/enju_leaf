FactoryBot.define do
  factory :form_of_work do |f|
    f.sequence(:name){|n| "form_of_work_#{n}"}
  end
end

# == Schema Information
#
# Table name: form_of_works
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
