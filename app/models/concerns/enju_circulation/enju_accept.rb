module EnjuCirculation
  module EnjuAccept
    extend ActiveSupport::Concern

    included do
      before_save :accept!, on: :create
    end

    def accept!
      circulation_status = CirculationStatus.find_by(name: 'Available On Shelf')
      item.update_column(:circulation_status_id, circulation_status.id) if circulation_status
      use_restriction = UseRestriction.find_by(name: 'Limited Circulation, Normal Loan Period')
      item.use_restriction = use_restriction if use_restriction
      item.index
    end
  end
end
