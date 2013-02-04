# -*- encoding: utf-8 -*-
class Library < ActiveRecord::Base
  attr_accessible :name, :display_name, :short_display_name, :zip_code, :street,
    :locality, :region, :telephone_number_1, :telephone_number_2, :fax_number,
    :note, :call_number_rows, :call_number_delimiter, :library_group_id,
    :country_id, :opening_hour, :isil, :position, :patron_id

  include MasterModel
  default_scope :order => 'libraries.position'
  scope :real, where('id != 1')
  has_many :shelves, :order => 'shelves.position'
  belongs_to :library_group, :validate => true
  has_many :events, :include => :event_category
  #belongs_to :holding_patron, :polymorphic => true, :validate => true
  belongs_to :patron #, :validate => true
  has_many :inter_library_loans, :foreign_key => 'to_library_id'
  has_many :inter_library_loans, :foreign_key => 'from_library_id'
  has_many :users
  belongs_to :country
  has_many :budgets
  has_many :statistics
  has_many :library_reports

  extend FriendlyId
  friendly_id :name
  geocoded_by :address
  #enju_calil_library

  has_paper_trail

  searchable do
    text :name, :display_name, :note, :address
    time :created_at
    time :updated_at
    integer :position
  end

  #validates_associated :library_group, :holding_patron
  validates_associated :library_group, :patron
  validates_presence_of :short_display_name, :library_group, :patron
  validates_uniqueness_of :short_display_name, :case_sensitive => false
  validates :display_name, :uniqueness => true
  validates :name, :format => {:with => /^[a-z][0-9a-z]{2,254}$/}
  before_validation :set_patron, :on => :create
  #before_save :set_calil_neighborhood_library
  after_validation :geocode, :if => :address_changed?

  after_create :create_shelf
  after_save :clear_all_cache
  after_destroy :clear_all_cache

  paginates_per 10

  def self.all_cache
    if Rails.env == 'production'
      Rails.cache.fetch('library_all'){Library.all}
    else
      Library.all
    end
  end

  def in_process_shelf
    self.shelves.find_by_open_access(9)
  end

  def article_shelf
    self.shelves.find_by_open_access(10)
  end

  def excludescope_shelf_ids
    self.shelves.collect {|c| c.id}
  end

  def clear_all_cache
    Rails.cache.delete('library_all')
  end

  def set_patron
    self.patron = Patron.new(
      :full_name => self.name
    )
  end

  def create_shelf
    #Shelf.create!(:name => "#{self.name}_default", :library => self)
    shelf_name = self.name 
    @shelf_default = Shelf.new(:name => "#{shelf_name}_default", :library_id => self.id)
    @shelf_in_process = Shelf.new(:name => "#{shelf_name}_in_process", :display_name => I18n.t('activerecord.attributes.shelf.in_process'), :open_access => 9,:library_id => self.id)
    @shelf_default.save!
    @shelf_in_process.save!
  end

  def closed?(date)
#    events.closing_days.collect{|c| c.start_at.beginning_of_day}.include?(date.beginning_of_day)
     events.closing_days.each do |c|
       return true if c.start_at.beginning_of_day <= date.beginning_of_day && c.end_at.end_of_day >= date.beginning_of_day
     end
     false
  end

  def web?
    return true if self.id == 1
    false
  end

  def self.web
    Library.find(1) rescue nil
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

  def destroy?
    #return false unless self.shelves.empty? && self.users.empty? && self.events.empty? && self.budgets.empty?
    return false unless self.shelves.size == 1 && self.shelves[0].open_access == 9 && self.shelves[0].items.empty? && self.users.empty? && self.events.empty? && self.budgets.empty?
    return false if self.id == 1
    return true
  end

  def address_changed?
    return true if region_changed? or locality_changed? or street_changed?
    false
  end
end

# == Schema Information
#
# Table name: libraries
#
#  id                          :integer         not null, primary key
#  patron_id                   :integer
#  patron_type                 :string(255)
#  name                        :string(255)     not null
#  display_name                :text
#  short_display_name          :string(255)     not null
#  zip_code                    :string(255)
#  street                      :text
#  locality                    :text
#  region                      :text
#  telephone_number_1          :string(255)
#  telephone_number_2          :string(255)
#  fax_number                  :string(255)
#  note                        :text
#  call_number_rows            :integer         default(1), not null
#  call_number_delimiter       :string(255)     default("|"), not null
#  library_group_id            :integer         default(1), not null
#  users_count                 :integer         default(0), not null
#  position                    :integer
#  country_id                  :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  deleted_at                  :datetime
#  opening_hour                :text
#  latitude                    :float
#  longitude                   :float
#  calil_systemid              :string(255)
#  calil_neighborhood_systemid :text
#

