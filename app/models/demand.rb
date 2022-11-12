class Demand < ApplicationRecord
  belongs_to :user
  belongs_to :item
  belongs_to :message
end

# == Schema Information
#
# Table name: demands
#
#  id         :bigint           not null, primary key
#  user_id    :bigint
#  item_id    :bigint
#  message_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
