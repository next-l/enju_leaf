class ThemeHasManifestation < ActiveRecord::Base
 
  acts_as_list
  default_scope :order => "position"
  attr_accessible :manifestation_id, :position, :theme_id
  
  belongs_to :theme
  belongs_to :manifestation

end


