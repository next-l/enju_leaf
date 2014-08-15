class Profile < ActiveRecord::Base
  attr_accessible :full_name, :keyword_list, :locale
  attr_accessible :full_name, :user_number, :library_id, :keyword_list, :note,
    :user_group_id, :user_id, :locale, :required_role_id, :expired_at,
    :user_attributes,
    :save_checkout_history,
    as: :admin

  enju_circulation_profile_model if defined?(EnjuCirculation)
  enju_search_log_profile_model if defined?(EnjuSearchLog)

  belongs_to :user
  belongs_to :library, validate: true
  belongs_to :user_group
  belongs_to :required_role, class_name: 'Role', foreign_key: 'required_role_id' #, validate: true

  validates_associated :user_group, :library
  validates_associated :user
  validates_presence_of :user_group, :library, :locale #, :user_number
  validates :user_number, :uniqueness => true, format: {with: /\A[0-9A-Za-z_]+\Z/}, allow_blank: true

  searchable do
    text :user_number, :full_name, :note
    string :user_number
    text :username do
      user.try(:username)
    end
    text :email do
      user.try(:email)
    end
    string :username do
      user.try(:username)
    end
    string :email do
      user.try(:email)
    end
    time :created_at
    time :updated_at
    boolean :active do
      user.try(:active_for_authentication?)
    end
  end

  before_validation :set_role_and_agent, on: :create
  before_save :set_expired_at
  accepts_nested_attributes_for :user

  def set_role_and_agent
    self.required_role = Role.where(name: 'Librarian').first
    self.locale = I18n.default_locale.to_s unless locale
  end

  def set_expired_at
    if expired_at.blank?
      if user_group.valid_period_for_new_user > 0
        self.expired_at = user_group.valid_period_for_new_user.days.from_now.end_of_day
      end
    end
  end
end

# == Schema Information
#
# Table name: profiles
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  user_group_id            :integer
#  library_id               :integer
#  locale                   :string(255)
#  user_number              :string(255)
#  full_name                :text
#  note                     :text
#  keyword_list             :text
#  required_role_id         :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  checkout_icalendar_token :string(255)
#  save_checkout_history    :boolean          default(FALSE), not null
#
