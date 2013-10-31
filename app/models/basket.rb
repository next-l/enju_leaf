require EnjuTrunkCirculation::Engine.root.join('app', 'models', 'basket') if defined?(EnjuTrunkCirculation)
class Basket < ActiveRecord::Base
  validates :basket_type, :uniqueness => { :scope => [:user_id, :basket_type] }, :if => Proc.new{ |b| b.basket_type > 0 }
  has_many :checked_manifestations, :dependent => :destroy
  has_many :manifestations, :through => :checked_manifestations
end
