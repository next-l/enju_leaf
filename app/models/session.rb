# http://guides.rails.info/securing_rails_applications/security.html
class Session < ActiveRecord::Base
  scope :will_expire, lambda {|date| {:conditions => ['updated_at < ?', date]}}
  def self.sweep(time_ago = nil)
    time = case time_ago
      when /^(\d+)m$/ then Time.zone.now - $1.to_i.minute
      when /^(\d+)h$/ then Time.zone.now - $1.to_i.hour
      when /^(\d+)d$/ then Time.zone.now - $1.to_i.day
      else Time.zone.now - 1.hour
    end
    self.delete_all "updated_at < '#{time.to_s(:db)}'"
  end

  def self.expire
    Session.sweep
    logger.info "#{Time.zone.now} sessions expired!"
  #rescue
  #  logger.info "#{Time.zone.now} expiring sessions failed!"
  end

end
