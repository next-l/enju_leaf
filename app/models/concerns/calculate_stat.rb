module CalculateStat
  extend ActiveSupport::Concern

  included do
    validates :start_date, :end_date, presence: true
    validate :check_date

    # 利用統計の集計を開始します。
    def self.calculate_stat
      self.not_calculated.each do |stat|
        stat.transition_to!(:started)
      end
    end
  end

  # 利用統計の日付をチェックします。
  def check_date
    if self.start_date && self.end_date
      if self.start_date >= self.end_date
        errors.add(:start_date)
        errors.add(:end_date)
      end
    end
  end

  # 利用統計の集計完了メッセージを送信します。
  def send_message(mailer)
    sender = User.find(1) #system
    message = Message.create!(
      recipient: user.username,
      sender: sender,
      body: mailer.body.raw_source,
      subject: mailer.subject
    )
  end
end
