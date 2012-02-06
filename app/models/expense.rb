class Expense < ActiveRecord::Base
  belongs_to :budget
  validates_numericality_of :price, :allow_blank => true
  validates_presence_of :budget_id, :item_id

  def item
    Item.find(self.item_id) rescue nil
  end
end

