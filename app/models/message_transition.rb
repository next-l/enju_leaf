class MessageTransition < ApplicationRecord
  belongs_to :message, inverse_of: :message_transitions
end

# == Schema Information
#
# Table name: message_transitions
#
#  id          :bigint           not null, primary key
#  to_state    :string
#  metadata    :jsonb            not null
#  sort_key    :integer
#  message_id  :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  most_recent :boolean          not null
#
