class UserCheckoutStat < ActiveRecord::Base
  include AASM
  include CalculateStat
  scope :not_calculated, :conditions => {:state => 'pending'}
  has_many :checkout_stat_has_users
  has_many :users, :through => :checkout_stat_has_users

  validates_presence_of :start_date, :end_date

  aasm_column :state
  aasm_state :pending
  aasm_state :completed

  aasm_initial_state :pending

  aasm_event :aasm_calculate do
    transitions :from => :pending, :to => :completed,
      :on_transition => :calculate_count
  end

  def self.per_page
    10
  end

  validate :check_date

  def check_date
    if self.start_date and self.end_date
      if self.start_date >= self.end_date
        errors.add(:start_date)
        errors.add(:end_date)
      end
    end
  end

  def calculate_count
    self.started_at = Time.zone.now
    User.find_each do |user|
      daily_count = user.checkouts.completed(self.start_date, self.end_date).size
      if daily_count > 0
        self.users << user
        sql = ['UPDATE checkout_stat_has_users SET checkouts_count = ? WHERE user_checkout_stat_id = ? AND user_id = ?', daily_count, self.id, user.id]
        ActiveRecord::Base.connection.execute(
          self.class.send(:sanitize_sql_array, sql)
        )
      end
    end
    self.completed_at = Time.zone.now
  end

end
