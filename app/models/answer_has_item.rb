class AnswerHasItem < ActiveRecord::Base
  belongs_to :answer
  belongs_to :item

  validates_uniqueness_of :item_id, :scope => :answer_id
  acts_as_list :scope => :answer_id
end
