require 'rails_helper'

RSpec.describe ItemCustomValue, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

# == Schema Information
#
# Table name: item_custom_values
#
#  id                      :bigint           not null, primary key
#  value                   :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  item_custom_property_id :bigint           not null
#  item_id                 :bigint           not null
#
# Indexes
#
#  index_item_custom_values_on_custom_item_property_and_item_id  (item_custom_property_id,item_id) UNIQUE
#  index_item_custom_values_on_custom_property_id                (item_custom_property_id)
#  index_item_custom_values_on_item_id                           (item_id)
#
# Foreign Keys
#
#  fk_rails_...  (item_custom_property_id => item_custom_properties.id)
#  fk_rails_...  (item_id => items.id)
#
