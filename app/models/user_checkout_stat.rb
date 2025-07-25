class UserCheckoutStat < ApplicationRecord
  include Statesman::Adapters::ActiveRecordQueries[
    transition_class: UserCheckoutStatTransition,
    initial_state: UserCheckoutStatStateMachine.initial_state
  ]
  include CalculateStat
  default_scope { order("user_checkout_stats.id DESC") }
  scope :not_calculated, -> { in_state(:pending) }
  has_many :checkout_stat_has_users, dependent: :destroy
  has_many :users, through: :checkout_stat_has_users
  belongs_to :user

  paginates_per 10
  attr_accessor :mode

  has_many :user_checkout_stat_transitions, autosave: false, dependent: :destroy

  def state_machine
    UserCheckoutStatStateMachine.new(self, transition_class: UserCheckoutStatTransition)
  end

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
           to: :state_machine

  def calculate_count!
    self.started_at = Time.zone.now
    User.find_each do |user|
      daily_count = user.checkouts.completed(start_date.beginning_of_day, end_date.tomorrow.beginning_of_day).size
      if daily_count.positive?
        users << user
        sql = [ "UPDATE checkout_stat_has_users SET checkouts_count = ? WHERE user_checkout_stat_id = ? AND user_id = ?", daily_count, id, user.id ]
        UserCheckoutStat.connection.execute(
          self.class.send(:sanitize_sql_array, sql)
        )
      end
    end
    self.completed_at = Time.zone.now
    transition_to!(:completed)

    mailer = UserCheckoutStatMailer.completed(self)
    mailer.deliver_later
    send_message(mailer)
  end
end

# == Schema Information
#
# Table name: user_checkout_stats
#
#  id           :bigint           not null, primary key
#  completed_at :datetime
#  end_date     :datetime
#  note         :text
#  start_date   :datetime
#  started_at   :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_user_checkout_stats_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
