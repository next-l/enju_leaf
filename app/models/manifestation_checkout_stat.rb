class ManifestationCheckoutStat < ActiveRecord::Base
  include CalculateStat
  scope :not_calculated, where(:state => 'pending')
  has_many :checkout_stat_has_manifestations
  has_many :manifestations, :through => :checkout_stat_has_manifestations

  state_machine :initial => :pending do
    before_transition :pending => :completed, :do => :calculate_count
    event :calculate do
      transition :pending => :completed
    end
  end

  paginates_per 10

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

  def self.get_manifestation_checkout_stats_tsv(manifestation_checkout_stat, stats)
    data = String.new
    data << "\xEF\xBB\xBF".force_encoding("UTF-8") + "\n"

    # manifestation_checkout_stat
    # term
    data << '"' + I18n.t('activerecord.attributes.manifestation_checkout_stat.start_date') + "\"\n"
    data << '"' + manifestation_checkout_stat.start_date.to_s + "\"\n"
    data << '"' + I18n.t('activerecord.attributes.manifestation_checkout_stat.end_date') + "\"\n"
    data << '"' + manifestation_checkout_stat.end_date.to_s + "\"\n"
    # state
    data << '"' + I18n.t('activerecord.attributes.manifestation_checkout_stat.state') + "\"\n"
    data << '"' + manifestation_checkout_stat.state + "\"\n"
    # note
    data << '"' + I18n.t('activerecord.attributes.manifestation_checkout_stat.note') + "\"\n"
    data << '"' + manifestation_checkout_stat.note + "\"\n"
    data << "\n"

    columns = [
      [:manifestation, 'activerecord.models.manifestation'],
      [:checkouts_count, 'activerecord.attributes.checkout_stat_has_manifestation.checkouts_count']
    ]
    # title column
    row = columns.map {|column| I18n.t(column[1])}
    data << '"'+row.join("\"\t\"")+"\"\n"

    stats.each do |stat|
      row = []
      columns.each do |column|
        case column[0]
        when :manifestation
          manifestation = ""
          manifestation = stat.manifestation.original_title if stat.manifestation
          row << manifestation
        when :reserves_count
          row << stat.checkouts_count
        end
      end
      data << '"' + row.join("\"\t\"") + "\"\n"
    end
    return data
  end
end

# == Schema Information
#
# Table name: manifestation_checkout_stats
#
#  id           :integer         not null, primary key
#  start_date   :datetime
#  end_date     :datetime
#  note         :text
#  state        :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  started_at   :datetime
#  completed_at :datetime
#

