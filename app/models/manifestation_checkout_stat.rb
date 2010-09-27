class ManifestationCheckoutStat < ActiveRecord::Base
  include CalculateStat
  scope :not_calculated, :conditions => {:state => 'pending'}
  has_many :checkout_stat_has_manifestations
  has_many :manifestations, :through => :checkout_stat_has_manifestations

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
    Manifestation.find_each do |manifestation|
      daily_count = Checkout.manifestations_count(self.start_date, self.end_date, manifestation)
      #manifestation.update_attributes({:daily_checkouts_count => daily_count, :total_count => manifestation.total_count + daily_count})
      if daily_count > 0
        self.manifestations << manifestation
        sql = ['UPDATE checkout_stat_has_manifestations SET checkouts_count = ? WHERE manifestation_checkout_stat_id = ? AND manifestation_id = ?', daily_count, self.id, manifestation.id]
        ActiveRecord::Base.connection.execute(
          self.class.send(:sanitize_sql_array, sql)
        )
      end
    end
    self.completed_at = Time.zone.now
  end
end
