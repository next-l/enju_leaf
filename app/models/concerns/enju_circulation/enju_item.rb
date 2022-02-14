module EnjuCirculation
  module EnjuItem
    extend ActiveSupport::Concern

    included do
      FOR_CHECKOUT_CIRCULATION_STATUS = [
        'Available On Shelf',
        'On Loan',
        'Waiting To Be Reshelved'
      ]
      FOR_CHECKOUT_USE_RESTRICTION = [
        'Available For Supply Without Return',
        'Limited Circulation, Long Loan Period',
        'Limited Circulation, Short Loan Period',
        'No Reproduction',
        'Overnight Only',
        'Renewals Not Permitted',
        'Supervision Required',
        'Term Loan',
        'User Signature Required',
        'Limited Circulation, Normal Loan Period'
      ]

      scope :for_checkout, ->(identifier_conditions = 'item_identifier IS NOT NULL') {
        includes(:circulation_status, :use_restriction).where(
          'circulation_statuses.name' => FOR_CHECKOUT_CIRCULATION_STATUS,
          'use_restrictions.name' => FOR_CHECKOUT_USE_RESTRICTION
        ).where(identifier_conditions)
      }
      scope :on_shelf, -> { includes(:shelf).references(:shelf).where('shelves.name != ?', 'web').where.not(circulation_status_id: CirculationStatus.find_by(name: 'Removed').id) }
      scope :available, -> { includes(:circulation_status).where.not('circulation_statuses.name' => 'Removed') }
      scope :removed, -> { includes(:circulation_status).where('circulation_statuses.name' => 'Removed') }

      has_many :checkouts
      has_many :checkins, dependent: :destroy
      has_many :reserves
      has_many :checked_items, dependent: :destroy
      has_many :baskets, through: :checked_items
      belongs_to :circulation_status
      belongs_to :checkout_type
      has_many :lending_policies, dependent: :destroy
      has_one :item_has_use_restriction, dependent: :destroy
      has_one :use_restriction, through: :item_has_use_restriction
      validates :circulation_status, :checkout_type, presence: true
      validate :check_circulation_status

      searchable do
        string :circulation_status do
          circulation_status.name
        end
      end
      accepts_nested_attributes_for :item_has_use_restriction

      before_update :delete_lending_policy
    end

    def set_circulation_status
      self.circulation_status = CirculationStatus.find_by(name: 'In Process') if circulation_status.nil?
    end

    def check_circulation_status
      #circulation_status.name_will_change!
      #return unless circulation_status.name_change.first == 'Removed'
      return unless circulation_status.name == 'Removed'

      errors[:base] << I18n.t('activerecord.errors.models.item.attributes.circulation_status_id.is_rented') if rented?
      errors[:base] << I18n.t('activerecord.errors.models.item.attributes.circulation_status_id.is_reserved') if reserved?
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
      return true if checkouts.not_returned.select(:item_id).detect{|checkout| checkout.item_id == id}

      false
    end

    def rented?
      rent?
    end

    def reserved_by_user?(user)
      if manifestation.next_reservation
        return true if manifestation.next_reservation.user == user
      end
      false
    end

    def available_for_checkout?
      if circulation_status.name == 'On Loan'
        false
      else
        manifestation.items.for_checkout.include?(self)
      end
    end

    def checkout!(user)
      if reserved_by_user?(user)
        manifestation.next_reservation.update(checked_out_at: Time.zone.now)
        manifestation.next_reservation.transition_to!(:completed)
        manifestation.reload
      end

      reload
      update!(circulation_status: CirculationStatus.find_by(name: 'On Loan'))
    end

    def checkin!
      self.circulation_status = CirculationStatus.find_by(name: 'Available On Shelf')
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

    def lending_rule(user)
      policy = lending_policies.find_by(user_group_id: user.profile.user_group.id)
      if policy
        policy
      else
        create_lending_policy(user)
      end
    end

    def not_for_loan?
      !manifestation.items.for_checkout.include?(self)
    end

    def create_lending_policy(user)
      rule = user.profile.user_group.user_group_has_checkout_types.find_by(checkout_type_id: checkout_type_id)
      return nil unless rule

      LendingPolicy.create!(
        item_id: id,
        user_group_id: rule.user_group_id,
        fixed_due_date: rule.fixed_due_date,
        loan_period: rule.checkout_period,
        renewal: rule.checkout_renewal_limit
      )
    end

    def delete_lending_policy
      return nil unless changes[:checkout_type_id]

      lending_policies.delete_all
    end

    def next_reservation
      Reserve.waiting.find_by(item_id: id)
    end

    def latest_checkout
      checkouts.not_returned.order(created_at: :desc).first
    end
  end
end
