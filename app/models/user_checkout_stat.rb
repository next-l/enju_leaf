class UserCheckoutStat < ActiveRecord::Base
  include CalculateStat
  default_scope :order => 'id DESC'
  scope :not_calculated, where(:state => 'pending')
  has_many :checkout_stat_has_users
  has_many :users, :through => :checkout_stat_has_users

  state_machine :initial => :pending do
    before_transition :pending => :completed, :do => :calculate_count
    event :calculate do
      transition :pending => :completed
    end
  end

  paginates_per 10

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

  def self.get_user_checkout_stats_tsv(user_checkout_stat, stats)
    data = String.new
    data << "\xEF\xBB\xBF".force_encoding("UTF-8") + "\n"

    # term
    data << '"' + I18n.t('activerecord.attributes.user_checkout_stat.start_date') + "\"\n"
    data << '"' + user_checkout_stat.start_date.to_s + "\"\n"
    data << '"' + I18n.t('activerecord.attributes.user_checkout_stat.end_date') + "\"\n"
    data << '"' + user_checkout_stat.end_date.to_s + "\"\n"
    # state
    data << '"' + I18n.t('activerecord.attributes.user_checkout_stat.state') + "\"\n"
    data << '"' + user_checkout_stat.state.to_s + "\"\n"
    # note
    data << '"' + I18n.t('activerecord.attributes.user_checkout_stat.note') + "\"\n"
    data << '"' + user_checkout_stat.note + "\"\n"
    data << "\n"

    # title column
    columns = [
      [:user, 'activerecord.models.user'],
      [:checkouts_count, 'activerecord.attributes.checkout_stat_has_user.checkouts_count']
    ]

    row = columns.map {|column| I18n.t(column[1])}
    data << '"'+row.join("\"\t\"")+"\"\n"

    stats.each do |stat|
      row = []
      columns.each do |column|
        case column[0]
        when :user
          user = ""
          user = stat.user.username if stat.user
          row << user
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
# Table name: user_checkout_stats
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

