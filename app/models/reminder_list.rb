class ReminderList < ActiveRecord::Base

  default_scope :order => 'id DESC'

  validates_presence_of :checkout_id, :status
  validate :check_checkout_id

  belongs_to :checkout

  def self.per_page
    10
  end

  def self.statuses
    #TODO
    [{:id => 0, :display_name => I18n.t('activerecord.attributes.reminder_list.status_name.accepted')},
     {:id => 1, :display_name => I18n.t('activerecord.attributes.reminder_list.status_name.called')}
    ]
  end

  def check_checkout_id
    unless self.checkout_id.blank?
      checkout = Checkout.find(self.checkout_id)
      errors[:base] << I18n.t('checkout.no_checkout') unless checkout
    end
  end

  def status_name
    case status
    when 0
      I18n.t('activerecord.attributes.reminder_list.status_name.accepted')
    when 1
      I18n.t('activerecord.attributes.reminder_list.status_name.called')
    end
  end

  searchable do
    integer :checkout_id 
    integer :status
    time :created_at
    time :updated_at
  end

end
