class Profile < ActiveRecord::Base
  enju_circulation_profile_model if defined?(EnjuCirculation)
  enju_search_log_profile_model if defined?(EnjuSearchLog)

  scope :administrators, -> { joins(user: :role).where('roles.name = ?', 'Administrator') }
  scope :librarians, -> { joins(user: :role).where('roles.name = ? OR roles.name = ?', 'Administrator', 'Librarian') }
  belongs_to :user, dependent: :destroy
  belongs_to :library, validate: true
  belongs_to :user_group
  belongs_to :required_role, class_name: 'Role', foreign_key: 'required_role_id' #, validate: true
  has_many :identities
  has_many :agents
  has_many :names
  accepts_nested_attributes_for :identities, allow_destroy: true, reject_if: :all_blank

  validates_associated :user_group, :library
  validates_associated :user
  validates_presence_of :user_group, :library, :locale #, :user_number
  validates :user_number, uniqueness: true, format: { with: /\A[0-9A-Za-z_]+\z/ }, allow_blank: true
  validates :user_id, uniqueness: true, allow_blank: true
  validates :birth_date, format: { with: /\A\d{4}-\d{1,2}-\d{1,2}\z/ }, allow_blank: true

  strip_attributes only: :user_number

  attr_accessor :birth_date, :locked

  searchable do
    text :user_number, :full_name, :full_name_transcription, :note
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
    integer :required_role_id
  end

  before_validation :set_role_and_agent, on: :create
  before_save :set_expired_at, :set_date_of_birth
  accepts_nested_attributes_for :user

  # 既定のユーザ権限を設定します。
  # @return [void]
  def set_role_and_agent
    self.required_role = Role.where(name: 'Librarian').first unless required_role
    self.locale = I18n.default_locale.to_s unless locale
  end

  # ユーザの有効期限を設定します。
  # @return [Time]
  def set_expired_at
    if expired_at.blank?
      if user_group.valid_period_for_new_user > 0
        self.expired_at = user_group.valid_period_for_new_user.days.from_now.end_of_day
      end
    end
  end

  # ユーザの誕生日を設定します。
  # @return [Time]
  def set_date_of_birth
    self.date_of_birth = Time.zone.parse(birth_date) if birth_date
  rescue ArgumentError
    nil
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
#  locale                   :string
#  user_number              :string
#  full_name                :text
#  note                     :text
#  keyword_list             :text
#  required_role_id         :integer
#  created_at               :datetime
#  updated_at               :datetime
#  checkout_icalendar_token :string
#  save_checkout_history    :boolean          default(FALSE), not null
#  expired_at               :datetime
#  save_search_history      :boolean
#  share_bookmarks          :boolean
#  full_name_transcription  :text
#  date_of_birth            :datetime
#
