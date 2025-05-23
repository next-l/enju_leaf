class UserGroupHasCheckoutType < ApplicationRecord
  scope :available_for_item, lambda { |item| where(checkout_type_id: item.checkout_type.id) }
  scope :available_for_carrier_type, lambda { |carrier_type| includes(checkout_type: :carrier_types).where("carrier_types.id" => carrier_type.id) }

  belongs_to :user_group
  belongs_to :checkout_type

  validates :checkout_type_id, uniqueness: { scope: :user_group_id }
  validates :checkout_limit, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :checkout_period, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :checkout_renewal_limit, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :reservation_limit, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :reservation_expired_period, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  acts_as_list scope: :user_group_id

  def self.update_current_checkout_count
    sql = [
      'SELECT count(checkouts.id) as current_checkout_count,
        profiles.user_group_id,
        items.checkout_type_id
        FROM profiles, checkouts LEFT OUTER JOIN items
        ON (checkouts.item_id = items.id)
        LEFT OUTER JOIN users
        ON (users.id = checkouts.user_id)
        WHERE checkouts.checkin_id IS NULL
        GROUP BY user_group_id, checkout_type_id;'
    ]
    UserGroupHasCheckoutType.find_by_sql(sql).each do |result|
      update_sql = [
        'UPDATE user_group_has_checkout_types
          SET current_checkout_count = ?
          WHERE user_group_id = ? AND checkout_type_id = ?;',
          result.current_checkout_count, result.user_group_id, result.checkout_type_id
      ]
      ActiveRecord::Base.connection.execute(
        send(:sanitize_sql_array, update_sql)
      )
    end
  end
end

# == Schema Information
#
# Table name: user_group_has_checkout_types
#
#  id                              :bigint           not null, primary key
#  checkout_limit                  :integer          default(0), not null
#  checkout_period                 :integer          default(0), not null
#  checkout_renewal_limit          :integer          default(0), not null
#  current_checkout_count          :integer
#  fixed_due_date                  :datetime
#  note                            :text
#  position                        :integer
#  reservation_expired_period      :integer          default(7), not null
#  reservation_limit               :integer          default(0), not null
#  set_due_date_before_closing_day :boolean          default(FALSE), not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  checkout_type_id                :bigint           not null
#  user_group_id                   :bigint           not null
#
# Indexes
#
#  index_user_group_has_checkout_types_on_checkout_type_id  (checkout_type_id)
#  index_user_group_has_checkout_types_on_user_group_id     (user_group_id,checkout_type_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (checkout_type_id => checkout_types.id)
#  fk_rails_...  (user_group_id => user_groups.id)
#
