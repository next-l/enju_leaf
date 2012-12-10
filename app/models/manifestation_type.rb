class ManifestationType < ActiveRecord::Base
  include MasterModel
  attr_accessible :display_name, :name, :note, :position
  default_scope :order => "position"
  has_many :manifestations

  def self.is_article?(id)
    manifestation_type = ManifestationType.find(id)
    if ['japanese_article', 'foreign_article'].include?(manifestation_type.name)
      return true
    end
    false
  end
end
