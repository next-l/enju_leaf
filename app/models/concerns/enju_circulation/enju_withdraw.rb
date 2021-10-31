module EnjuCirculation
  module EnjuWithdraw
    extend ActiveSupport::Concern

    included do
      before_create :withdraw!
      validate :check_item
    end

    def withdraw!
      circulation_status = CirculationStatus.find_by(name: 'Removed')
      item.update_column(:circulation_status_id, circulation_status.id) if circulation_status
      item.use_restriction = UseRestriction.find_by(name: 'Not For Loan')
      item.index!
    end

    def check_item
      errors.add(:item_id, :is_rented) if item.try(:rent?)
      errors.add(:item_id, :is_reserved) if item.try(:reserved?)
    end
  end
end
