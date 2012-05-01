# -*- encoding: utf-8 -*-
class Item < ActiveRecord::Base
  scope :on_shelf, where('shelf_id != 1')
  scope :on_web, where(:shelf_id => 1)
  has_one :exemplify
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

  attr_accessor :library_id, :manifestation_id

  if defined?(EnjuCirculation)
    FOR_CHECKOUT_CIRCULATION_STATUS = [
      'Available On Shelf',
      'On Loan',
      'Waiting To Be Reshelved'
    ]
    FOR_CHECKOUT_USE_RESTRICTION = [
      'Available For Supply Without Return',
      'Limited Circulation, Long Loan Period',
      'Limited Circulation, Short Loan Period',
      'No Reproduction',
      'Overnight Only',
      'Renewals Not Permitted',
      'Supervision Required',
      'Term Loan',
      'User Signature Required',
      'Limited Circulation, Normal Loan Period'
    ]
    scope :for_checkout, includes(:circulation_status, :use_restriction).where(
        'circulation_statuses.name' => FOR_CHECKOUT_CIRCULATION_STATUS,
        'use_restrictions.name' => FOR_CHECKOUT_USE_RESTRICTION
      ).where('item_identifier IS NOT NULL')
    scope :removed, includes(:circulation_status).where('circulation_statuses.name' => 'Removed')
    has_many :checkouts
    has_many :reserves
    has_many :reserved_patrons, :through => :reserves, :class_name => 'Patron'
    has_many :checked_items, :dependent => :destroy
    has_many :baskets, :through => :checked_items
    belongs_to :circulation_status, :validate => true
    belongs_to :checkout_type
    has_many :lending_policies, :dependent => :destroy
    has_one :item_has_use_restriction, :dependent => :destroy
    has_one :use_restriction, :through => :item_has_use_restriction
    validates_associated :circulation_status, :checkout_type
    validates_presence_of :circulation_status, :checkout_type
    before_save :set_use_restriction
    searchable do
      integer :circulation_status_id
    end
    attr_accessor :use_restriction_id

    def set_circulation_status
      self.circulation_status = CirculationStatus.where(:name => 'In Process').first if self.circulation_status.nil?
    end

    def set_use_restriction
      if self.use_restriction_id
        self.use_restriction = UseRestriction.where(:id => self.use_restriction_id).first
      else
        return if use_restriction
        self.use_restriction = UseRestriction.where(:name => 'Limited Circulation, Normal Loan Period').first
      end
    end

    def checkout_status(user)
       user.user_group.user_group_has_checkout_types.where(:checkout_type_id => self.checkout_type.id).first
    end

    def reserved?
      return true if manifestation.next_reservation
      false
    end

    def rent?
      return true if self.checkouts.not_returned.select(:item_id).detect{|checkout| checkout.item_id == self.id}
      false
    end

    def reserved_by_user?(user)
      if manifestation.next_reservation
        return true if manifestation.next_reservation.user == user
      end
      false
    end

    def available_for_checkout?
      if circulation_status.name == 'On Loan'
        false
      else
        manifestation.items.for_checkout.include?(self)
      end
    end

    def checkout!(user)
      self.circulation_status = CirculationStatus.where(:name => 'On Loan').first
      if self.reserved_by_user?(user)
        manifestation.next_reservation.update_attributes(:checked_out_at => Time.zone.now)
        manifestation.next_reservation.sm_complete!
      end
      save!
    end

    def checkin!
      self.circulation_status = CirculationStatus.where(:name => 'Available On Shelf').first
      save(:validate => false)
    end

    def retain(librarian)
      Item.transaction do
        reservation = manifestation.next_reservation
        unless reservation.nil?
          reservation.item = self
          reservation.sm_retain!
          reservation.send_message(librarian)
        end
      end
    end

    def lending_rule(user)
      lending_policies.where(:user_group_id => user.user_group.id).first
    end

    def not_for_loan?
      !manifestation.items.for_checkout.include?(self)
    end
  end

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
#  owns_count            :integer         default(0), not null
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

