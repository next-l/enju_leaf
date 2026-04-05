class ManifestationReserveStat < ApplicationRecord
  include Statesman::Adapters::ActiveRecordQueries[
    transition_class: ManifestationReserveStatTransition,
    initial_state: ManifestationReserveStatStateMachine.initial_state
  ]
  include CalculateStat
  default_scope { order("manifestation_reserve_stats.id DESC") }
  scope :not_calculated, -> { in_state(:pending) }
  has_many :reserve_stat_has_manifestations, dependent: :destroy
  has_many :manifestations, through: :reserve_stat_has_manifestations
  belongs_to :user

  paginates_per 10
  attr_accessor :mode

  has_many :manifestation_reserve_stat_transitions, autosave: false, dependent: :destroy

  def state_machine
    ManifestationReserveStatStateMachine.new(self, transition_class: ManifestationReserveStatTransition)
  end

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
           to: :state_machine

  def calculate_count!
    Manifestation.find_each do |manifestation|
      daily_count = manifestation.reserves.created(start_date.beginning_of_day, end_date.tomorrow.beginning_of_day).size
      # manifestation.update_attributes({daily_reserves_count: daily_count, total_count: manifestation.total_count + daily_count})
      if daily_count.positive?
        manifestations << manifestation
        sql = [ "UPDATE reserve_stat_has_manifestations SET reserves_count = ? WHERE manifestation_reserve_stat_id = ? AND manifestation_id = ?", daily_count, id, manifestation.id ]
        ManifestationReserveStat.connection.execute(
          self.class.send(:sanitize_sql_array, sql)
        )
      end
    end
    transition_to!(:completed)

    mailer = ManifestationReserveStatMailer.completed(self)
    mailer.deliver_later
    send_message(mailer)
  end
end

# ## Schema Information
#
# Table name: `manifestation_reserve_stats`
# Database name: `primary`
#
# ### Columns
#
# Name              | Type               | Attributes
# ----------------- | ------------------ | ---------------------------
# **`id`**          | `bigint`           | `not null, primary key`
# **`end_date`**    | `datetime`         | `not null`
# **`note`**        | `text`             |
# **`start_date`**  | `datetime`         | `not null`
# **`created_at`**  | `datetime`         | `not null`
# **`updated_at`**  | `datetime`         | `not null`
# **`user_id`**     | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_manifestation_reserve_stats_on_user_id`:
#     * **`user_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`user_id => users.id`**
#
