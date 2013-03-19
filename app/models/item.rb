# -*- encoding: utf-8 -*-
class Item < ActiveRecord::Base
  attr_accessible :call_number, :item_identifier, :circulation_status_id,
    :checkout_type_id, :shelf_id, :include_supplements, :note, :url, :price,
    :acquired_at, :bookstore_id, :missing_since, :budget_type_id,
    :manifestation_id, :library_id, :required_role_id #,:exemplify_attributes
  scope :on_shelf, where('shelf_id != 1')
  scope :on_web, where(:shelf_id => 1)
  scope :accepted_between, lambda{|from, to| includes(:accept).where('items.created_at BETWEEN ? AND ?', Time.zone.parse(from).beginning_of_day, Time.zone.parse(to).end_of_day)}
  has_one :exemplify, :dependent => :destroy
  has_one :manifestation, :through => :exemplify
  has_many :owns
  has_many :patrons, :through => :owns
  belongs_to :shelf, :counter_cache => true, :validate => true
  delegate :display_name, :to => :shelf, :prefix => true
  belongs_to :bookstore, :validate => true
  has_many :donates
  has_many :donors, :through => :donates, :source => :patron
  belongs_to :required_role, :class_name => 'Role', :foreign_key => 'required_role_id', :validate => true
  has_one :resource_import_result
  belongs_to :budget_type
  has_one :accept
  #accepts_nested_attributes_for :exemplify
  #before_save :create_manifestation

  validates_associated :shelf, :bookstore
  validates :manifestation_id, :presence => true, :on => :create
  validates :item_identifier, :allow_blank => true, :uniqueness => true,
    :format => {:with => /\A[0-9A-Za-z_]+\Z/}
  validates :url, :url => true, :allow_blank => true, :length => {:maximum => 255}
  validates_date :acquired_at, :allow_blank => true

  has_paper_trail
  normalize_attributes :item_identifier

  searchable do
    text :item_identifier, :note, :title, :creator, :contributor, :publisher
    string :item_identifier
    string :library do
      shelf.library.name if shelf
    end
    integer :required_role_id
    integer :manifestation_id do
      manifestation.id if manifestation
    end
    integer :shelf_id
    integer :patron_ids, :multiple => true
    time :created_at
    time :updated_at
  end

  enju_circulation_item_model if defined?(EnjuCirculation)

  attr_accessor :library_id, :manifestation_id

  if defined?(EnjuInventory)
    has_many :inventories, :dependent => :destroy
    has_many :inventory_files, :through => :inventories
    searchable do
      integer :inventory_file_ids, :multiple => true
    end

    def self.inventory_items(inventory_file, mode = 'not_on_shelf')
      item_ids = Item.select(:id).collect(&:id)
      inventory_item_ids = inventory_file.items.select('items.id').collect(&:id)
      case mode
      when 'not_on_shelf'
        Item.where(:id => (item_ids - inventory_item_ids))
      when 'not_in_catalog'
        Item.where(:id => (inventory_item_ids - item_ids))
      end
    rescue
      nil
    end
  end

  if defined?(EnjuQuestion)
    has_many :answer_has_items, :dependent => :destroy
    has_many :answers, :through => :answer_has_items
  end

  if defined?(EnjuInterLibraryLoan)
    has_many :inter_library_loans, :dependent => :destroy
    def inter_library_loaned?
      true if self.inter_library_loans.size > 0
    end
  end

  def self.per_page
    10
  end

  def title
    manifestation.try(:original_title)
  end

  def creator
    manifestation.try(:creator)
  end

  def contributor
    manifestation.try(:contributor)
  end

  def publisher
    manifestation.try(:publisher)
  end

  def shelf_name
    shelf.name
  end

  def hold?(library)
    return true if self.shelf.library == library
    false
  end

  def owned(patron)
    owns.where(:patron_id => patron.id).first
  end

  def library_url
    "#{LibraryGroup.site_config.url}libraries/#{self.shelf.library.name}"
  end

  def manifestation_url
    Addressable::URI.parse("#{LibraryGroup.site_config.url}manifestations/#{self.manifestation.id}").normalize.to_s if self.manifestation
  end

  def deletable?
    if circulation_status.name == 'Removed'
      return false
    else
      if defined?(EnjuCirculation)
        checkouts.not_returned.empty?
      else
        true
      end
    end
  end

  def create_manifestation
    if manifestation_id
      self.manifestation = Manifestation.find(manifestation_id)
    end
  end
end
# == Schema Information
#
# Table name: items
#
#  id                    :integer         not null, primary key
#  call_number           :string(255)
#  item_identifier       :string(255)
#  circulation_status_id :integer         default(5), not null
#  checkout_type_id      :integer         default(1), not null
#  created_at            :datetime        not null
#  updated_at            :datetime        not null
#  deleted_at            :datetime
#  shelf_id              :integer         default(1), not null
#  include_supplements   :boolean         default(FALSE), not null
#  checkouts_count       :integer         default(0), not null
#  note                  :text
#  url                   :string(255)
#  price                 :integer
#  lock_version          :integer         default(0), not null
#  required_role_id      :integer         default(1), not null
#  state                 :string(255)
#  required_score        :integer         default(0), not null
#  acquired_at           :datetime
#  bookstore_id          :integer
#  missing_since         :datetime
#  budget_type_id        :integer
#

