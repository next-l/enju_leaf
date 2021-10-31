module EnjuCirculation
  module EnjuCarrierType
    extend ActiveSupport::Concern

    included do
      has_many :carrier_type_has_checkout_types, dependent: :destroy
      has_many :checkout_types, through: :carrier_type_has_checkout_types
      accepts_nested_attributes_for :carrier_type_has_checkout_types, allow_destroy: true, reject_if: :all_blank
    end
  end
end
