class CarrierType < ActiveRecord::Base
  include MasterModel
  default_scope :order => "position"
  has_many :manifestations
  if defined?(EnjuCirculation)
    has_many :carrier_type_has_checkout_types, :dependent => :destroy
    has_many :checkout_types, :through => :carrier_type_has_checkout_types
  end

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

# == Schema Information
#
# Table name: carrier_types
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#

