class ManifestationExtext < ActiveRecord::Base
  attr_accessible :manifestation_id, :name, :display_name, :position, :value
 
  belongs_to :manifestation

  acts_as_list
  default_scope :order => "position"

  def self.add_extexts(extexts, manifestation_id)
    return [] if extexts.blank?
    list = []
    extexts.each do |key, value|
      next if value.blank?
      manifestation_extext = ManifestationExtext.new(
          name: key,
          value: value,
          manifestation_id: manifestation_id
        )
      manifestation_extext.save
      list << manifestation_extext
    end
    return list
  end
end
