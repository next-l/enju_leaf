class ThemeHasManifestation < ActiveRecord::Base
  attr_accessible :manifestation_id, :position, :theme_id
  
  belongs_to :theme
  belongs_to :manifestation

end


