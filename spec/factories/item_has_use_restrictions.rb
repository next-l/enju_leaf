FactoryBot.define do
  factory :item_has_use_restriction do |f|
    f.item_id{FactoryBot.create(:item).id}
    f.use_restriction_id{FactoryBot.create(:use_restriction).id}
  end
end

# == Schema Information
#
# Table name: item_has_use_restrictions
#
#  id                 :bigint           not null, primary key
#  item_id            :integer          not null
#  use_restriction_id :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
