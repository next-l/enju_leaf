class NdlaRecord < ApplicationRecord
  belongs_to :agent
  validates :body, presence: true, uniqueness: true
end

# == Schema Information
#
# Table name: ndla_records
#
#  id         :bigint           not null, primary key
#  agent_id   :bigint
#  body       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
