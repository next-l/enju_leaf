require 'rails_helper'

describe Inventory do
  # pending "add some examples to (or delete) #{__FILE__}"

end

# == Schema Information
#
# Table name: inventories
#
#  id                 :bigint           not null, primary key
#  item_id            :bigint
#  inventory_file_id  :bigint
#  note               :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  item_identifier    :string           not null
#  current_shelf_name :string           not null
#
