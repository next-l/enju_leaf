class ManifestationExinfo < ActiveRecord::Base
  attr_accessible :manifestation_id, :name, :position, :value, :manifestation

  acts_as_list
  default_scope :order => "position"

  belongs_to :manifestations

  #TODO exinfo
  #単体の登録のみを確認
=begin
  def self.add_exinfo(name, value, manifestation_id)
    return [] if value.blank?
    values = value.split(/,/)
    list = []
    values.each do |exinfo|
      exinfo = ManifestationExinfo.new
      exinfo.name = name
      exinfo.value = value
      exinfo.manifestation_id = manifestation_id
      exinfo.save
      list << exinfo
    end
    list
  end
=end
end
