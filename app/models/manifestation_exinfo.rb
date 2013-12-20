class ManifestationExinfo < ActiveRecord::Base
  attr_accessible :manifestation_id, :name, :position, :value, :manifestation

  acts_as_list
  default_scope :order => "position"

  belongs_to :manifestation

  def self.add_extexts(exinfos, manifestation_id)
    return [] if exinfos.blank?
    list = []
    exinfos.each do |key, value|
      next if value.blank?
      manifestation_exinfo = ManifestationExinfo.new(
          name: key,
          value: value,
          manifestation_id: manifestation_id
        )
      manifestation_exinfo.save
      list << manifestation_exinfo
    end
    return list
  end
end
