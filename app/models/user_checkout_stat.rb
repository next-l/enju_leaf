class UserCheckoutStat < ActiveRecord::Base
  include CalculateStat
  scope :not_calculated, :conditions => {:state => 'pending'}
  has_many :checkout_stat_has_users
  has_many :users, :through => :checkout_stat_has_users

  state_machine :initial => :pending do
    before_transition :pending => :completed, :do => :calculate_count
    event :calculate do
      transition :pending => :completed
    end
  end

  def self.per_page
    10
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
