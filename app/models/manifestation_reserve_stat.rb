class ManifestationReserveStat < ActiveRecord::Base
  include CalculateStat
  scope :not_calculated, :conditions => {:state => 'pending'}
  has_many :reserve_stat_has_manifestations
  has_many :manifestations, :through => :reserve_stat_has_manifestations

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
    Resource.find_each do |manifestation|
      daily_count = manifestation.reserves.created(self.start_date, self.end_date).size
      #manifestation.update_attributes({:daily_reserves_count => daily_count, :total_count => manifestation.total_count + daily_count})
      if daily_count > 0
        self.manifestations << manifestation
        sql = ['UPDATE reserve_stat_has_manifestations SET reserves_count = ? WHERE manifestation_reserve_stat_id = ? AND manifestation_id = ?', daily_count, self.id, manifestation.id]
        ActiveRecord::Base.connection.execute(
          self.class.send(:sanitize_sql_array, sql)
        )
      end
    end
    self.completed_at = Time.zone.now
  end
end
