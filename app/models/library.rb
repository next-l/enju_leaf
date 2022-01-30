class Library < ApplicationRecord
  include MasterModel
  include EnjuEvent::EnjuLibrary

  default_scope { order('libraries.position') }
  scope :real, -> { where('id != 1') }
  has_many :shelves
  belongs_to :library_group, validate: true
  has_many :profiles
  belongs_to :country, optional: true

  extend FriendlyId
  friendly_id :name
  geocoded_by :address

  searchable do
    text :name, :display_name, :note, :address
    time :created_at
    time :updated_at
    integer :position
  end

  validates_associated :library_group
  validates :short_display_name, presence: true
  validates :library_group, presence: true
  validates_uniqueness_of :short_display_name, case_sensitive: false
  validates_uniqueness_of :isil, allow_blank: true
  validates :display_name, uniqueness: true
  validates :name, format: { with: /\A[a-z][0-9a-z\-_]{1,253}[0-9a-z]\Z/ }
  validates :isil, format: { with: /\A[A-Za-z]{1,4}-[A-Za-z0-9\/:\-]{2,11}\z/ }, allow_blank: true
  after_validation :geocode, if: :address_changed?
  after_create :create_shelf
  after_save :clear_all_cache
  after_destroy :clear_all_cache

  def self.all_cache
    if Rails.env.production?
      Rails.cache.fetch('library_all'){ Library.all }
    else
      Library.all
    end
  end

  def clear_all_cache
    Rails.cache.delete('library_all')
  end

  def create_shelf
    shelf = Shelf.new
    shelf.name = "#{name}_default"
    shelf.library = self
    shelf.save!
  end

  def web?
    return true if id == 1
    false
  end

  def self.web
    Library.find(1)
  end

  def address(locale = I18n.locale)
    case locale.to_sym
    when :ja
      "#{region.to_s.localize(locale)}#{locality.to_s.localize(locale)}#{street.to_s.localize(locale)}"
    else
      "#{street.to_s.localize(locale)} #{locality.to_s.localize(locale)} #{region.to_s.localize(locale)}"
    end
  rescue Psych::SyntaxError
    nil
  end

  def address_changed?
    return true if saved_change_to_region? || saved_change_to_locality? || saved_change_to_street?
    false
  end

  if defined?(EnjuEvent)
    has_many :events

    def closed?(date)
      events.closing_days.map{ |c|
        c.start_at.beginning_of_day
      }.include?(date.beginning_of_day)
    end
  end

  if defined?(EnjuInterLibraryLoan)
    has_many :inter_library_loans, foreign_key: 'borrowing_library_id'
  end
end

# == Schema Information
#
# Table name: libraries
#
#  id                    :integer          not null, primary key
#  name                  :string           not null
#  display_name          :text
#  short_display_name    :string           not null
#  zip_code              :string
#  street                :text
#  locality              :text
#  region                :text
#  telephone_number_1    :string
#  telephone_number_2    :string
#  fax_number            :string
#  note                  :text
#  call_number_rows      :integer          default(1), not null
#  call_number_delimiter :string           default("|"), not null
#  library_group_id      :integer          not null
#  users_count           :integer          default(0), not null
#  position              :integer
#  country_id            :integer
#  created_at            :datetime
#  updated_at            :datetime
#  deleted_at            :datetime
#  opening_hour          :text
#  isil                  :string
#  latitude              :float
#  longitude             :float
#
