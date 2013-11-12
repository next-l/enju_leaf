class ThemeHasManifestation < ActiveRecord::Base
 
  belongs_to :theme
  belongs_to :manifestation

  acts_as_list
  default_scope :order => "position"
  attr_accessible :manifestation_id, :position, :theme_id, :theme, :manifestation 
  
end


