module EnjuCirculation
  module EnjuUser
    extend ActiveSupport::Concern

    included do
      has_many :checkouts, dependent: :nullify
      has_many :reserves, dependent: :destroy
      has_many :reserved_manifestations, through: :reserves, source: :manifestation
      has_many :checkout_stat_has_users
      has_many :user_checkout_stats, through: :checkout_stat_has_users
      has_many :reserve_stat_has_users
      has_many :user_reserve_stats, through: :reserve_stat_has_users
      has_many :baskets, dependent: :destroy

      before_destroy :check_item_before_destroy
    end

    def check_item_before_destroy
      # TODO: 貸出記録を残す場合
      if checkouts.size.positive?
        raise 'This user has items still checked out.'
      end
    end

    def checked_item_count
      checkout_count = {}
      CheckoutType.find_each do |checkout_type|
        # 資料種別ごとの貸出中の冊数を計算
        checkout_count[:"#{checkout_type.name}"] = checkouts.count_by_sql(["
          SELECT count(item_id) FROM checkouts
            WHERE item_id IN (
              SELECT id FROM items
                WHERE checkout_type_id = ?
            )
            AND user_id = ? AND checkin_id IS NULL", checkout_type.id, id]
        )
      end
      checkout_count
    end

    def reached_reservation_limit?(manifestation)
      return true if profile.user_group.user_group_has_checkout_types.available_for_carrier_type(manifestation.carrier_type).where(user_group_id: profile.user_group.id).collect(&:reservation_limit).max.to_i <= reserves.waiting.size

      false
    end

    def has_overdue?(day = 1)
      true if checkouts.where(checkin_id: nil).where(Checkout.arel_table[:due_date].lt day.days.ago).count >= 1
    end
  end
end
