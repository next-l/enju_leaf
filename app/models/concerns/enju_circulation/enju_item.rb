module EnjuCirculation
  module EnjuItem
    extend ActiveSupport::Concern

    included do
      FOR_CHECKOUT_CIRCULATION_STATUS = [
        "Available On Shelf",
        "On Loan",
        "Waiting To Be Reshelved"
      ]
      FOR_CHECKOUT_USE_RESTRICTION = [
        "Available For Supply Without Return",
        "Limited Circulation, Long Loan Period",
        "Limited Circulation, Short Loan Period",
        "No Reproduction",
        "Overnight Only",
        "Renewals Not Permitted",
        "Supervision Required",
        "Term Loan",
        "User Signature Required",
        "Limited Circulation, Normal Loan Period"
      ]

      scope :for_checkout, ->(identifier_conditions = "item_identifier IS NOT NULL") {
        includes(:circulation_status, :use_restriction).where(
          "circulation_statuses.name" => FOR_CHECKOUT_CIRCULATION_STATUS,
          "use_restrictions.name" => FOR_CHECKOUT_USE_RESTRICTION
        ).where(identifier_conditions)
      }

      has_many :checkouts, dependent: :restrict_with_exception
      has_many :checkins, dependent: :destroy
      has_many :reserves, dependent: :nullify
      has_many :checked_items, dependent: :destroy
      has_many :baskets, through: :checked_items
      belongs_to :circulation_status
      belongs_to :checkout_type
      has_one :item_has_use_restriction, dependent: :destroy
      has_one :use_restriction, through: :item_has_use_restriction
      validate :check_circulation_status

      searchable do
        string :circulation_status do
          circulation_status.name
        end
      end
      accepts_nested_attributes_for :item_has_use_restriction
    end

    def set_circulation_status
      self.circulation_status = CirculationStatus.find_by(name: "In Process") if circulation_status.nil?
    end

    def check_circulation_status
      return unless circulation_status.name == "Removed"

      errors.add(:base, I18n.t("activerecord.errors.models.item.attributes.circulation_status_id.is_rented")) if rented?
      errors.add(:base, I18n.t("activerecord.errors.models.item.attributes.circulation_status_id.is_reserved")) if reserved?
    end

    def checkout_status(user)
      return nil unless user

      user.profile.user_group.user_group_has_checkout_types.find_by(checkout_type_id: checkout_type.id)
    end

    def reserved?
      return true if manifestation.next_reservation

      false
    end

    def rent?
      return true if checkouts.not_returned.select(:item_id).detect { |checkout| checkout.item_id == id }

      false
    end

    def rented?
      rent?
    end

    def user_reservation(user)
      user.reserves.waiting.order("reserves.created_at").find_by(manifestation: manifestation)
    end

    def available_for_checkout?
      if circulation_status.name == "On Loan"
        false
      else
        manifestation.items.for_checkout.include?(self)
      end
    end

    def checkout!(user)
      Item.transaction do
        reserve = user_reservation(user)
        if reserve && !reserve.state_machine.in_state?(:completed)
          reserve.checked_out_at = Time.zone.now
          reserve.state_machine.transition_to!(:completed)
        end

        update!(circulation_status: CirculationStatus.find_by(name: "On Loan"))
      end
    end

    def checkin!
      self.circulation_status = CirculationStatus.find_by(name: "Available On Shelf")
      save!
    end

    def retain(librarian)
      self.class.transaction do
        reservation = manifestation.next_reservation
        if reservation
          reservation.item = self
          reservation.transition_to!(:retained) unless reservation.retained?
          reservation.send_message(librarian)
        end
      end
    end

    def retained?
      manifestation.reserves.retained.each do |reserve|
        if reserve.item == self
          return true
        end
      end
      false
    end

    def not_for_loan?
      !manifestation.items.for_checkout.include?(self)
    end

    def next_reservation
      Reserve.waiting.find_by(item_id: id)
    end

    def latest_checkout
      checkouts.not_returned.order(created_at: :desc).first
    end
  end
end
