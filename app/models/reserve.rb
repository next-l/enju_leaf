class Reserve < ApplicationRecord
  include Statesman::Adapters::ActiveRecordQueries[
    transition_class: ReserveTransition,
    initial_state: ReserveStateMachine.initial_state
  ]
  scope :hold, -> { where.not(item_id: nil) }
  scope :not_hold, -> { where(item_id: nil) }
  scope :waiting, -> {not_in_state(:completed, :canceled, :expired).where('canceled_at IS NULL AND (expired_at > ? OR expired_at IS NULL)', Time.zone.now).order('reserves.id DESC')}
  scope :retained, -> {in_state(:retained).where.not(retained_at: nil)}
  scope :completed, -> {in_state(:completed).where.not(checked_out_at: nil)}
  scope :canceled, -> {in_state(:canceled).where.not(canceled_at: nil)}
  scope :postponed, -> {in_state(:postponed).where.not(postponed_at: nil)}
  scope :will_expire_retained, lambda {|datetime| in_state(:retained).where('checked_out_at IS NULL AND canceled_at IS NULL AND expired_at <= ?', datetime).order('expired_at')}
  scope :will_expire_pending, lambda {|datetime| in_state(:pending).where('checked_out_at IS NULL AND canceled_at IS NULL AND expired_at <= ?', datetime).order('expired_at')}
  scope :created, lambda {|start_date, end_date| where('created_at >= ? AND created_at < ?', start_date, end_date)}
  scope :not_sent_expiration_notice_to_patron, -> {in_state(:expired).where(expiration_notice_to_patron: false)}
  scope :not_sent_expiration_notice_to_library, -> {in_state(:expired).where(expiration_notice_to_library: false)}
  scope :sent_expiration_notice_to_patron, -> {in_state(:expired).where(expiration_notice_to_patron: true)}
  scope :sent_expiration_notice_to_library, -> {in_state(:expired).where(expiration_notice_to_library: true)}
  scope :not_sent_cancel_notice_to_patron, -> {in_state(:canceled).where(expiration_notice_to_patron: false)}
  scope :not_sent_cancel_notice_to_library, -> {in_state(:canceled).where(expiration_notice_to_library: false)}
  belongs_to :user
  belongs_to :manifestation, touch: true
  belongs_to :librarian, class_name: 'User', optional: true
  belongs_to :item, touch: true, optional: true
  belongs_to :request_status_type
  belongs_to :pickup_location, class_name: 'Library', optional: true

  validates :expired_at, date: true, allow_blank: true
  validate :manifestation_must_include_item
  validate :available_for_reservation?, on: :create
  validates :item_id, presence: true, if: proc{|reserve|
    if item_id_changed?
      if reserve.completed? || reserve.retained?
        if item_id_change[0]
          if item_id_change[1]
            true
          else
            false
          end
        else
          false
        end
      end
    elsif reserve.retained?
      true
    end
  }
  validate :valid_item?
  validate :retained_by_other_user?
  before_validation :set_manifestation, on: :create
  before_validation :set_item
  validate :check_expired_at
  before_validation :set_user, on: :update
  before_validation :set_request_status, on: :create
  after_save do
    if item
      item.checkouts.map{|checkout| checkout.index}
      Sunspot.commit
    end
  end

  attr_accessor :user_number, :item_identifier, :force_retaining

  paginates_per 10

  def self.transition_class
    ReserveTransition
  end

  def state_machine
    ReserveStateMachine.new(self, transition_class: ReserveTransition)
  end

  has_many :reserve_transitions, autosave: false, dependent: :destroy

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
           to: :state_machine

  searchable do
    text :username do
      user.try(:username)
    end
    string :username do
      user.try(:username)
    end
    string :user_number do
      user.profile.try(:user_number)
    end
    time :created_at
    text :item_identifier do
      manifestation.items.pluck(:item_identifier) if manifestation
    end
    text :title do
      manifestation.try(:titles)
    end
    boolean :hold do |reserve|
      hold.include?(reserve)
    end
    string :state do
      current_state
    end
    string :title_transcription do
      manifestation.try(:title_transcription)
    end
    integer :manifestation_id
  end

  def set_manifestation
    self.manifestation = item.manifestation if item
  end

  def set_item
    identifier = item_identifier.to_s.strip
    if identifier.present?
      item = Item.find_by(item_identifier: identifier)
      self.item = item
    end
  end

  def set_user
    number = user_number.to_s.strip
    if number.present?
      self.user = Profile.find_by(user_number: number).try(:user)
    end
  end

  def valid_item?
    if item_identifier.present?
      item = Item.find_by(item_identifier: item_identifier)
      errors.add(:base, I18n.t('reserve.invalid_item')) unless item
    end
  end

  def retained_by_other_user?
    return nil if force_retaining == '1'

    if item && !retained?
      if Reserve.retained.where(item_id: item.id).count.positive?
        errors.add(:base, I18n.t('reserve.attempt_to_update_retained_reservation'))
      end
    end
  end

  def set_request_status
    self.request_status_type = RequestStatusType.find_by(name: 'In Process')
  end

  def check_expired_at
    if canceled_at.blank? && expired_at?
      unless completed?
        if expired_at.beginning_of_day < Time.zone.now
          errors.add(:base, I18n.t('reserve.invalid_date'))
        end
      end
    end
  end

  def next_reservation
    if item
      Reserve.waiting.where(manifestation_id: item.manifestation.id).readonly(false).first
    end
  end

  def send_message(sender = nil)
    sender ||= User.find(1) # TODO: システムからのメッセージの発信者
    Reserve.transaction do
      mailer = nil

      case current_state
      when 'requested'
        mailer = ReserveMailer.accepted(self)
      when 'canceled'
        mailer = ReserveMailer.canceled(self)
      when 'expired'
        mailer = ReserveMailer.expired(self)
      when 'retained'
        mailer = ReserveMailer.retained(self)
      when 'postponed'
        mailer = ReserveMailer.postponed(self)
      else
        raise 'status not defined'
      end

      if mailer
        mailer.deliver_later
        Message.create!(
          subject: mailer.subject,
          sender: sender,
          recipient: user.username,
          body: mailer.body.to_s
        )

        Message.create!(
          subject: mailer.subject,
          sender: sender,
          recipient: sender.username,
          body: mailer.body.to_s
        )
      end
    end
  end

  def self.expire
    Reserve.transaction do
      will_expire_retained(Time.zone.now.beginning_of_day).readonly(false).map{|r|
        r.transition_to!(:expired)
        r.send_message
      }
      will_expire_pending(Time.zone.now.beginning_of_day).readonly(false).map{|r|
        r.transition_to!(:expired)
        r.send_message
      }
    end
  end

  def checked_out_now?
    if user && manifestation
      true if !(user.checkouts.not_returned.pluck(:item_id) & manifestation.items.pluck('items.id')).empty?
    end
  end

  def available_for_reservation?
    if manifestation
      if checked_out_now?
        errors.add(:base, I18n.t('reserve.this_manifestation_is_already_checked_out'))
      end

      if manifestation.is_reserved_by?(user)
        errors.add(:base, I18n.t('reserve.this_manifestation_is_already_reserved'))
      end
      if user.try(:reached_reservation_limit?, manifestation)
        errors.add(:base, I18n.t('reserve.excessed_reservation_limit'))
      end

      expired_period = manifestation.try(:reservation_expired_period, user)
      if expired_period.nil?
        errors.add(:base, I18n.t('reserve.this_patron_cannot_reserve'))
      end
    end
  end

  def completed?
    ['canceled', 'expired', 'completed'].include?(current_state)
  end

  def retained?
    return true if current_state == 'retained'

    false
  end

  private

  def do_request
    assign_attributes(request_status_type: RequestStatusType.find_by(name: 'In Process'), item_id: nil, retained_at: nil)
    save!
  end

  def retain
    # TODO: 「取り置き中」の状態を正しく表す
    assign_attributes(request_status_type: RequestStatusType.find_by(name: 'In Process'), retained_at: Time.zone.now)
    Reserve.transaction do
      item.next_reservation.try(:transition_to!, :postponed)
      save!
    end
  end

  def expire
    Reserve.transaction do
      assign_attributes(request_status_type: RequestStatusType.find_by(name: 'Expired'), canceled_at: Time.zone.now)
      reserve = next_reservation
      if reserve
        reserve.item = item
        self.item = nil
        save!
        reserve.transition_to!(:retained)
      end
    end
    logger.info "#{Time.zone.now} reserve_id #{id} expired!"
  end

  def cancel
    Reserve.transaction do
      assign_attributes(request_status_type: RequestStatusType.find_by(name: 'Cannot Fulfill Request'), canceled_at: Time.zone.now)
      save!
      reserve = next_reservation
      if reserve
        reserve.item = item
        self.item = nil
        save!
        reserve.transition_to!(:retained)
      end
    end
  end

  def checkout
    assign_attributes(request_status_type: RequestStatusType.find_by(name: 'Available For Pickup'), checked_out_at: Time.zone.now)
    save!
  end

  def postpone
    assign_attributes(
      request_status_type: RequestStatusType.find_by(name: 'In Process'),
      item_id: nil,
      retained_at: nil,
      postponed_at: Time.zone.now
    )
    save!
  end

  def manifestation_must_include_item
    if manifestation && item && !completed?
      errors.add(:base, I18n.t('reserve.invalid_item')) unless manifestation.items.include?(item)
    end
  end

  if defined?(EnjuInterLibraryLoan)
    has_one :inter_library_loan
  end
end

# == Schema Information
#
# Table name: reserves
#
#  id                           :integer          not null, primary key
#  user_id                      :integer          not null
#  manifestation_id             :integer          not null
#  item_id                      :integer
#  request_status_type_id       :integer          not null
#  checked_out_at               :datetime
#  created_at                   :datetime
#  updated_at                   :datetime
#  canceled_at                  :datetime
#  expired_at                   :datetime
#  expiration_notice_to_patron  :boolean          default(FALSE)
#  expiration_notice_to_library :boolean          default(FALSE)
#  pickup_location_id           :integer
#  retained_at                  :datetime
#  postponed_at                 :datetime
#  lock_version                 :integer          default(0), not null
#
