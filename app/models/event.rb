class Event < ApplicationRecord
  scope :closing_days, -> { includes(:event_category).where('event_categories.name' => 'closed') }
  scope :on, lambda {|datetime| where('start_at >= ? AND start_at < ?', datetime.beginning_of_day, datetime.tomorrow.beginning_of_day + 1)}
  scope :past, lambda {|datetime| where('end_at <= ?', Time.zone.parse(datetime).beginning_of_day)}
  scope :upcoming, lambda {|datetime| where('start_at >= ?', Time.zone.parse(datetime).beginning_of_day)}
  scope :at, lambda {|library| where(library_id: library.id)}

  belongs_to :event_category, validate: true
  belongs_to :library, validate: true
  belongs_to :place, optional: true
  has_many :picture_files, as: :picture_attachable
  has_many :participates, dependent: :destroy
  has_many :agents, through: :participates
  has_one :event_import_result

  searchable do
    text :name, :note
    integer :library_id
    time :created_at
    time :updated_at
    time :start_at
    time :end_at
  end

  validates :name, :library, :event_category, :start_at, :end_at, presence: true
  validates_associated :library, :event_category
  validate :check_date
  before_validation :set_date
  before_validation :set_display_name, on: :create

  paginates_per 10

  def set_date
    if all_day
      set_all_day
    end
  end

  def set_all_day
    if start_at and end_at
      self.start_at = start_at.beginning_of_day
      self.end_at = end_at.end_of_day
    end
  end

  def check_date
    if start_at and end_at
      if start_at >= end_at
        errors.add(:start_at)
        errors.add(:end_at)
      end
    end
  end

  def set_display_name
    self.display_name = name if display_name.blank?
  end

  # CSVのヘッダ
  # @param [String] role 権限
  def self.csv_header(role: 'Guest')
    Event.new.to_hash(role: role).keys
  end

  # CSV出力用のハッシュ
  # @param [String] role 権限
  def to_hash(role: 'Guest')
    record = {
      name: name,
      display_name: display_name,
      event_category: event_category.try(:name),
      library: library.try(:name),
      start_at: start_at,
      end_at: end_at,
      all_day: all_day,
      note: note,
      created_at: created_at,
      updated_at: updated_at
    }

    record
  end

  # TSVでのエクスポート
  # @param [String] role 権限
  # @param [String] col_sep 区切り文字
  def self.export(role: 'Guest', col_sep: "\t")
    file = Tempfile.create('event_export') do |f|
      f.write Event.csv_header(role: role).to_csv(col_sep: col_sep)
      Event.find_each do |event|
        f.write event.to_hash(role: role).values.to_csv(col_sep: col_sep)
      end

      f.rewind
      f.read
    end
  end
end

# == Schema Information
#
# Table name: events
#
#  id                :integer          not null, primary key
#  library_id        :integer          not null
#  event_category_id :integer          not null
#  name              :string
#  note              :text
#  start_at          :datetime
#  end_at            :datetime
#  all_day           :boolean          default(FALSE), not null
#  deleted_at        :datetime
#  display_name      :text
#  created_at        :datetime
#  updated_at        :datetime
#  place_id          :integer
#
