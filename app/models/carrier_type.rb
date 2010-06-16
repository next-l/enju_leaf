class CarrierType < ActiveRecord::Base
  include MasterModel
  default_scope :order => "position"
  has_many :resources
  has_many :carrier_type_has_checkout_types, :dependent => :destroy
  has_many :checkout_types, :through => :carrier_type_has_checkout_types

  def mods_type
    case name
    when 'print'
      'text'
    else
      # TODO: その他のタイプ
      'software, multimedia'
    end
  end
end
