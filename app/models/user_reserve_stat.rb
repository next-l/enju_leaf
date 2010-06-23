class UserReserveStat < ActiveRecord::Base
  include CalculateStat
  scope :not_calculated, :conditions => {:state => 'pending'}
  has_many :reserve_stat_has_users
  has_many :users, :through => :reserve_stat_has_users

  validates_presence_of :start_date, :end_date
  validate :check_date

  state_machine :initial => :pending do
    before_transition :pending => :completed, :do => :calculate_count
    event :calculate do
      transition :pending => :completed
    end
  end

  def self.per_page
    10
  end

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
      daily_count = user.reserves.created(self.start_date, self.end_date).size
      if daily_count > 0
        self.users << user
        sql = ['UPDATE reserve_stat_has_users SET reserves_count = ? WHERE user_reserve_stat_id = ? AND user_id = ?', daily_count, self.id, user.id]
        ActiveRecord::Base.connection.execute(
          self.class.send(:sanitize_sql_array, sql)
        )
      end
    end
    self.completed_at = Time.zone.now
  end
end
