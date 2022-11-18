class Donate < ApplicationRecord
  belongs_to :agent
  belongs_to :item
end

# == Schema Information
#
# Table name: donates
#
#  id         :bigint           not null, primary key
#  agent_id   :bigint           not null
#  item_id    :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
