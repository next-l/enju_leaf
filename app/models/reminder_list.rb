class ReminderList < ActiveRecord::Base

  default_scope :order => 'id DESC'

  belongs_to :checkout

  def self.per_page
    10
  end

  def status_name
    case status
    when 0
      I18n.t('activerecord.attributes.reminder_list.status_name.accepted')
    when 1
      I18n.t('activerecord.attributes.reminder_list.status_name.called')
    end
  end
end
