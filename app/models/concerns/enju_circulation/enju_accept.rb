module EnjuCirculation
  module EnjuAccept
    extend ActiveSupport::Concern

    included do
      before_create :accept!
      after_create do
        item.save
      end
    end

    def accept!
      item.circulation_status = CirculationStatus.find_by(name: 'Available On Shelf')
      item.use_restriction = UseRestriction.find_by(name: 'Limited Circulation, Normal Loan Period')
    end
  end
end
