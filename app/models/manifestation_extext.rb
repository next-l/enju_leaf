class ManifestationExtext < ActiveRecord::Base
  attr_accessible :manifestation_id, :name, :position, :value
 
  belongs_to :manifestation

  acts_as_list
  default_scope :order => "position"

end
