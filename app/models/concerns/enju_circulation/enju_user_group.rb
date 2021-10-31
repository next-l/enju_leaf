module EnjuCirculation
  module EnjuUserGroup
    extend ActiveSupport::Concern

    included do
      has_many :user_group_has_checkout_types, dependent: :destroy
      has_many :checkout_types, through: :user_group_has_checkout_types
      has_many :lending_policies
      accepts_nested_attributes_for :user_group_has_checkout_types, allow_destroy: true, reject_if: :all_blank

      validates :number_of_day_to_notify_due_date,
                :number_of_day_to_notify_overdue,
                :number_of_time_to_notify_overdue,
                numericality: { greater_than_or_equal_to: 0 }
    end
  end
end
