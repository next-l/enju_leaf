class AnswerHasItem < ApplicationRecord
  belongs_to :answer
  belongs_to :item

  validates :item_id, uniqueness: { scope: :answer_id }
  acts_as_list scope: :answer_id
end

# == Schema Information
#
# Table name: answer_has_items
#
#  id         :integer          not null, primary key
#  answer_id  :integer
#  item_id    :integer
#  position   :integer
#  created_at :datetime
#  updated_at :datetime
#
