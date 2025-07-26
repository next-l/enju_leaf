FactoryBot.define do
  factory :item_has_use_restriction do |f|
    f.item_id {FactoryBot.create(:item).id}
    f.use_restriction_id {FactoryBot.create(:use_restriction).id}
  end
end

# == Schema Information
#
# Table name: item_has_use_restrictions
#
#  id                 :bigint           not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  item_id            :bigint           not null
#  use_restriction_id :bigint           not null
#
# Indexes
#
#  index_item_has_use_restrictions_on_item_and_use_restriction  (item_id,use_restriction_id) UNIQUE
#  index_item_has_use_restrictions_on_use_restriction_id        (use_restriction_id)
#
# Foreign Keys
#
#  fk_rails_...  (item_id => items.id)
#  fk_rails_...  (use_restriction_id => use_restrictions.id)
#
