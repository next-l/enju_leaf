FactoryBot.define do
  factory :classification do |f|
    f.sequence(:category){|n| "classification_#{n}"}
    f.classification_type_id{FactoryBot.create(:classification_type).id}
  end
end

# == Schema Information
#
# Table name: classifications
#
#  id                     :bigint           not null, primary key
#  parent_id              :bigint
#  category               :string           not null
#  note                   :text
#  classification_type_id :bigint           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  lft                    :integer
#  rgt                    :integer
#  manifestation_id       :bigint
#  url                    :string
#  label                  :string
#
