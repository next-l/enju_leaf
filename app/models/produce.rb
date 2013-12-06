require EnjuTrunkFrbr::Engine.root.join('app', 'models', 'produce')
class Produce < ActiveRecord::Base
  has_paper_trail
end

