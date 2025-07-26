class MessageTransition < ApplicationRecord
  belongs_to :message, inverse_of: :message_transitions
end

# == Schema Information
#
# Table name: message_transitions
#
#  id          :bigint           not null, primary key
#  metadata    :jsonb            not null
#  most_recent :boolean          not null
#  sort_key    :integer
#  to_state    :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  message_id  :bigint
#
# Indexes
#
#  index_message_transitions_on_message_id               (message_id)
#  index_message_transitions_on_sort_key_and_message_id  (sort_key,message_id) UNIQUE
#  index_message_transitions_parent_most_recent          (message_id,most_recent) UNIQUE WHERE most_recent
#
