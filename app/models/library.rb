# -*- encoding: utf-8 -*-
class Library < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'libraries.position'
  scope :real, :conditions => ['id != 1']
  has_many :shelves, :order => 'shelves.position'
  belongs_to :library_group, :validate => true
  has_many :events, :include => :event_category
  #belongs_to :holding_patron, :polymorphic => true, :validate => true
  belongs_to :patron, :validate => true
  has_many :inter_library_loans, :foreign_key => 'borrowing_library_id'
  has_many :users
  belongs_to :country

  #acts_as_soft_deletable
  has_friendly_id :name
  geocoded_by :address
  #enju_calil_library

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
  validates_uniqueness_of :display_name
  validates_format_of :name, :with => /^[a-z][0-9a-z]{2,254}$/
  before_validation :set_patron, :on => :create
  #before_save :set_calil_neighborhood_library
  after_validation :fetch_coordinates
  after_create :create_shelf
  after_create :clear_all_cache
  after_destroy :clear_all_cache

  def self.per_page
    10
  end

  def clear_all_cache
    Rails.cache.delete('library_all')
  end

  def set_patron
    patron = Patron.create!(:full_name => self.name)
    self.patron = patron
  end

  def create_shelf
    Shelf.create!(:name => "#{self.name}_default", :library => self)
  end

  def set_calil_neighborhood_library
    self.calil_neighborhood_systemid = self.calil_library(self.access_calil).collect{|l| l[:systemid]}.uniq.join(',')
  end

  def closed?(date)
    events.closing_days.collect{|c| c.start_at.beginning_of_day}.include?(date.beginning_of_day)
  end

  def web?
    return true if self.id == 1
    false
  end

  def self.web
    Library.find(1)
  end

  def address
    self.region.to_s + self.locality.to_s + " " + self.street.to_s
  rescue
    nil
  end

end
