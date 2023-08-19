require 'rails_helper'

describe Order do
  #pending "add some examples to (or delete) #{__FILE__}"

end

# == Schema Information
#
# Table name: orders
#
#  id                  :bigint           not null, primary key
#  order_list_id       :bigint           not null
#  purchase_request_id :bigint           not null
#  position            :integer
#  state               :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
