class OrderListTransition < ApplicationRecord
  belongs_to :order_list, inverse_of: :order_list_transitions
end

# == Schema Information
#
# Table name: order_list_transitions
#
#  id            :bigint           not null, primary key
#  metadata      :jsonb            not null
#  most_recent   :boolean          not null
#  sort_key      :integer
#  to_state      :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  order_list_id :integer
#
# Indexes
#
#  index_order_list_transitions_on_order_list_id               (order_list_id)
#  index_order_list_transitions_on_sort_key_and_order_list_id  (sort_key,order_list_id) UNIQUE
#  index_order_list_transitions_parent_most_recent             (order_list_id,most_recent) UNIQUE WHERE most_recent
#
