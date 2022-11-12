class BookmarkStat < ApplicationRecord
  include Statesman::Adapters::ActiveRecordQueries[
    transition_class: UserCheckoutStatTransition,
    initial_state: UserCheckoutStatStateMachine.initial_state
  ]
  include CalculateStat
  default_scope { order('bookmark_stats.id DESC') }
  scope :not_calculated, -> {in_state(:pending)}
  has_many :bookmark_stat_has_manifestations, dependent: :destroy
  has_many :manifestations, through: :bookmark_stat_has_manifestations

  paginates_per 10

  has_many :bookmark_stat_transitions, autosave: false, dependent: :destroy

  def state_machine
    BookmarkStatStateMachine.new(self, transition_class: BookmarkStatTransition)
  end

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
    to: :state_machine

  def calculate_count!
    self.started_at = Time.zone.now
    Manifestation.find_each do |manifestation|
      daily_count = Bookmark.manifestations_count(start_date, end_date, manifestation)
      # manifestation.update_attributes({:daily_bookmarks_count => daily_count, :total_count => manifestation.total_count + daily_count})
      if daily_count > 0
        self.manifestations << manifestation
        sql = ['UPDATE bookmark_stat_has_manifestations SET bookmarks_count = ? WHERE bookmark_stat_id = ? AND manifestation_id = ?', daily_count, self.id, manifestation.id]
        ActiveRecord::Base.connection.execute(
          self.class.send(:sanitize_sql_array, sql)
        )
      end
    end
    self.completed_at = Time.zone.now
    transition_to!(:completed)
  end

  private
  def self.transition_class
    BookmarkStatTransition
  end

  def self.initial_state
    :pending
  end
end

# == Schema Information
#
# Table name: bookmark_stats
#
#  id           :integer          not null, primary key
#  start_date   :datetime
#  end_date     :datetime
#  started_at   :datetime
#  completed_at :datetime
#  note         :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
