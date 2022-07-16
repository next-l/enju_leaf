module EnjuCirculation
  module EnjuAccept
    extend ActiveSupport::Concern

    included do
      before_create :accept!
    end

    def accept!
      circulation_status = CirculationStatus.find_by(name: 'Available On Shelf')
      item.circulation_status = circulation_status if circulation_status
      use_restriction = UseRestriction.find_by(name: 'Limited Circulation, Normal Loan Period')
      item.use_restriction = use_restriction if use_restriction
      item.index
    end
  end
end
