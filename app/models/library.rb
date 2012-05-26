# -*- encoding: utf-8 -*-
class Library < ActiveRecord::Base
  attr_accessible :name, :display_name, :short_display_name, :zip_code, :street,
    :locality, :region, :telephone_number_1, :telephone_number_2, :fax_number,
    :note, :call_number_rows, :call_number_delimiter, :library_group_id,
    :country_id, :opening_hour, :isil

  include MasterModel
  default_scope :order => 'libraries.position'
  scope :real, where('id != 1')
  has_many :shelves, :order => 'shelves.position'
  belongs_to :library_group, :validate => true
  has_many :users
  belongs_to :country

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
  validates_presence_of :short_display_name, :library_group
  validates_uniqueness_of :short_display_name, :case_sensitive => false
  validates_uniqueness_of :isil, :allow_blank => true
  validates :display_name, :uniqueness => true
  validates :name, :format => {:with => /^[a-z][0-9a-z]{2,254}$/}
  validates :isil, :format => {:with => /^[A-Za-z]{1,4}-[A-Za-z0-9\/:\-]{2,11}$/}, :allow_blank => true
  #before_save :set_calil_neighborhood_library
  after_validation :geocode, :if => :address_changed?
  after_create :create_shelf
  after_save :clear_all_cache
  after_destroy :clear_all_cache

  def self.per_page
    10
  end

  def self.all_cache
    if Rails.env == 'production'
      Rails.cache.fetch('library_all'){Library.all}
    else
      Library.all
    end
  end

  def clear_all_cache
    Rails.cache.delete('library_all')
  end

  def create_shelf
    shelf = Shelf.new
    shelf.name = "#{self.name}_default"
    shelf.library = self
    shelf.save!
  end

  def web?
    return true if self.id == 1
    false
  end

  def self.web
    Library.find(1)
  end

  def address(locale = I18n.locale)
    case locale.to_sym
    when :ja
      "#{self.region.to_s.localize(locale)}#{self.locality.to_s.localize(locale)}#{self.street.to_s.localize(locale)}"
    else
      "#{self.street.to_s.localize(locale)} #{self.locality.to_s.localize(locale)} #{self.region.to_s.localize(locale)}"
    end
  rescue
    nil
  end

  def address_changed?
    return true if region_changed? or locality_changed? or street_changed?
    false
  end

  if defined?(EnjuEvent)
    has_many :events, :include => :event_category

    def closed?(date)
      events.closing_days.collect{|c| c.start_at.beginning_of_day}.include?(date.beginning_of_day)
    end
  end

  if defined?(EnjuInterLibraryLoan)
    has_many :inter_library_loans, :foreign_key => 'borrowing_library_id'
  end
end

# == Schema Information
#
# Table name: libraries
#
#  id                    :integer         not null, primary key
#  name                  :string(255)     not null
#  display_name          :text
#  short_display_name    :string(255)     not null
#  zip_code              :string(255)
#  street                :text
#  locality              :text
#  region                :text
#  telephone_number_1    :string(255)
#  telephone_number_2    :string(255)
#  fax_number            :string(255)
#  note                  :text
#  call_number_rows      :integer         default(1), not null
#  call_number_delimiter :string(255)     default("|"), not null
#  library_group_id      :integer         default(1), not null
#  users_count           :integer         default(0), not null
#  position              :integer
#  country_id            :integer
#  created_at            :datetime        not null
#  updated_at            :datetime        not null
#  deleted_at            :datetime
#  opening_hour          :text
#  latitude              :float
#  longitude             :float
#  isil                  :string(255)
#

