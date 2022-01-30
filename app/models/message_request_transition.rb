class MessageRequestTransition < ApplicationRecord
  include Statesman::Adapters::ActiveRecordTransition
  
  belongs_to :message_request, inverse_of: :message_request_transitions
end

# == Schema Information
#
# Table name: message_request_transitions
#
#  id                 :bigint           not null, primary key
#  to_state           :string
#  metadata           :text             default({})
#  sort_key           :integer
#  message_request_id :bigint
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  most_recent        :boolean          not null
#
