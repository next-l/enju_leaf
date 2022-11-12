class ManifestationReserveStat < ApplicationRecord
  include Statesman::Adapters::ActiveRecordQueries[
    transition_class: ManifestationReserveStatTransition,
    initial_state: ManifestationReserveStatStateMachine.initial_state
  ]
  include CalculateStat
  default_scope {order('manifestation_reserve_stats.id DESC')}
  scope :not_calculated, -> {in_state(:pending)}
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
    self.started_at = Time.zone.now
    Manifestation.find_each do |manifestation|
      daily_count = manifestation.reserves.created(start_date.beginning_of_day, end_date.tomorrow.beginning_of_day).size
      # manifestation.update_attributes({daily_reserves_count: daily_count, total_count: manifestation.total_count + daily_count})
      if daily_count.positive?
        manifestations << manifestation
        sql = ['UPDATE reserve_stat_has_manifestations SET reserves_count = ? WHERE manifestation_reserve_stat_id = ? AND manifestation_id = ?', daily_count, id, manifestation.id]
        ManifestationReserveStat.connection.execute(
          self.class.send(:sanitize_sql_array, sql)
        )
      end
    end
    self.completed_at = Time.zone.now
    transition_to!(:completed)

    mailer = ManifestationReserveStatMailer.completed(self)
    mailer.deliver_later
    send_message(mailer)
  end
end

# == Schema Information
#
# Table name: manifestation_reserve_stats
#
#  id           :bigint           not null, primary key
#  start_date   :datetime
#  end_date     :datetime
#  note         :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  started_at   :datetime
#  completed_at :datetime
#  user_id      :integer
#
