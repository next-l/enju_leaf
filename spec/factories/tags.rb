FactoryBot.define do
  factory :tag do |f|
    f.sequence(:name){|n| "tag_#{n}"}
  end
end

# == Schema Information
#
# Table name: tags
#
#  id             :integer          not null, primary key
#  name           :string
#  taggings_count :integer          default(0)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
