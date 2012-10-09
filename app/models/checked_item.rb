require EnjuTrunkCirculation::Engine.root.join('app', 'models', 'checked_item')
class CheckedItem < ActiveRecord::Base
  attr_accessible :item_identifier, :ignore_restriction

end
