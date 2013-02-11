require EnjuTrunkFrbr::Engine.root.join('app', 'models', 'exemplify')
class Exemplify < ActiveRecord::Base
  attr_accessible :manifestation_id, :item_id, :position
  self.extend ItemsHelper

  has_paper_trail
end


