class CarrierType < ApplicationRecord
  include MasterModel
  include EnjuCirculation::EnjuCarrierType
  has_many :manifestations, dependent: :restrict_with_exception
  has_one_attached :attachment

  before_save do
    attachment.purge if delete_attachment == '1'
  end

  attr_accessor :delete_attachment

  def mods_type
    case name
    when 'volume'
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
#  id           :bigint           not null, primary key
#  name         :string           not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
