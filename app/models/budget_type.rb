class BudgetType < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'budget_types.position'
  has_many :items
end
