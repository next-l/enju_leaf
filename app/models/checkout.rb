require EnjuTrunkCirculation::Engine.root.join('app', 'models', 'checkout')
class Checkout < ActiveRecord::Base
    attr_accessible :librarian_id, :item_id, :basket_id, :due_date, :created_at
end
