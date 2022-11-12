FactoryBot.define do
  factory :tag do |f|
    f.sequence(:name){|n| "tag_#{n}"}
  end
end

# == Schema Information
#
# Table name: tags
#
#  id             :bigint           not null, primary key
#  name           :string           not null
#  taggings_count :integer          default(0)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
