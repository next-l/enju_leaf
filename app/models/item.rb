class Item < ApplicationRecord
  scope :available, -> {}
  scope :on_shelf, -> { includes(:shelf).references(:shelf).where.not(shelves: { name: 'web' }) }
  scope :on_web, -> { includes(:shelf).references(:shelf).where('shelves.name = ?', 'web') }
  scope :available_for, -> user {
    unless user.try(:has_role?, 'Librarian')
      on_shelf
    end
  }

  include EnjuLibrary::EnjuItem
  include EnjuCirculation::EnjuItem
  include EnjuInventory::EnjuItem

  delegate :display_name, to: :shelf, prefix: true
  has_many :owns, dependent: :destroy
  has_many :agents, through: :owns
  has_many :donates, dependent: :destroy
  has_many :donors, through: :donates, source: :agent
  has_one :resource_import_result
  belongs_to :manifestation, touch: true
  belongs_to :bookstore, optional: true
  belongs_to :required_role, class_name: 'Role'
  belongs_to :budget_type, optional: true
  has_one :accept, dependent: :destroy
  has_one :withdraw, dependent: :destroy
  has_many :item_custom_values, -> { joins(:item_custom_property).order(:position) }, inverse_of: :item, dependent: :destroy

  belongs_to :shelf, counter_cache: true
  accepts_nested_attributes_for :item_custom_values, reject_if: :all_blank

  scope :accepted_between, lambda{|from, to| includes(:accept).where('items.created_at BETWEEN ? AND ?', Time.zone.parse(from).beginning_of_day, Time.zone.parse(to).end_of_day)}
  validates :item_identifier, allow_blank: true, uniqueness: true,
    format: {with: /\A[0-9A-Za-z_]+\Z/}
  validates :binding_item_identifier, allow_blank: true,
    format: {with: /\A[0-9A-Za-z_]+\Z/}
  validates :url, url: true, allow_blank: true, length: { maximum: 255 }
  validates :acquired_at, date: true, allow_blank: true

  strip_attributes only: [:item_identifier, :binding_item_identifier,
    :call_number, :binding_call_number, :url]

  searchable do
    text :item_identifier, :note, :title, :creator, :contributor, :publisher,
      :binding_item_identifier
    string :item_identifier, multiple: true do
      [item_identifier, binding_item_identifier]
    end
    integer :required_role_id
    integer :manifestation_id
    integer :shelf_id
    integer :agent_ids, multiple: true
    time :created_at
    time :updated_at
    time :acquired_at
  end

  after_save do
    manifestation.index
    Sunspot.commit
  end
  after_destroy do
    manifestation.index
    Sunspot.commit
  end

  attr_accessor :library_id

  paginates_per 10

  def title
    manifestation&.original_title
  end

  def creator
    manifestation&.creator
  end

  def contributor
    manifestation&.contributor
  end

  def publisher
    manifestation&.publisher
  end

  def owned(agent)
    owns.find_by(agent_id: agent.id)
  end

  def manifestation_url
    Addressable::URI.parse("#{LibraryGroup.site_config.url}manifestations/#{manifestation.id}").normalize.to_s if manifestation
  end

  def removable?
    if defined?(EnjuCirculation)
      return false if circulation_status.name == 'Removed'
      return false if checkouts.exists?

      true
    else
      true
    end
  end

  def self.csv_header(role: 'Guest')
    Item.new.to_hash(role: role).keys
  end

  def to_hash(role: 'Guest')
    record = {
      item_id: id,
      item_identifier: item_identifier,
      binding_item_identifier: binding_item_identifier,
      call_number: call_number,
      library: shelf&.library&.name,
      shelf: shelf&.name,
      item_note: note,
      accepted_at: accept&.created_at,
      acquired_at: acquired_at,
      item_created_at: created_at,
      item_updated_at: updated_at
    }

    if ['Administrator', 'Librarian'].include?(role)
      record.merge!({
        bookstore: bookstore&.name,
        budget_type: budget_type&.name,
        item_required_role: required_role.name,
        item_price: price,
        memo: memo
      })

      ItemCustomProperty.order(:position).each do |custom_property|
        custom_value = item_custom_values.find_by(item_custom_property: custom_property)
        record[:"item:#{custom_property.name}"] = custom_value.try(:value)
      end

      if defined?(EnjuCirculation)
        record.merge!({
          use_restriction: use_restriction&.name,
          circulation_status: circulation_status&.name,
          checkout_type: checkout_type&.name,
          total_checkouts: checkouts.count
        })
      end
    end

    record
  end
end

# == Schema Information
#
# Table name: items
#
#  id                      :bigint           not null, primary key
#  call_number             :string
#  item_identifier         :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  shelf_id                :bigint           default(1), not null
#  include_supplements     :boolean          default(FALSE), not null
#  note                    :text
#  url                     :string
#  price                   :integer
#  lock_version            :integer          default(0), not null
#  required_role_id        :bigint           default(1), not null
#  required_score          :integer          default(0), not null
#  acquired_at             :datetime
#  bookstore_id            :bigint
#  budget_type_id          :bigint
#  circulation_status_id   :bigint           default(5), not null
#  checkout_type_id        :bigint           default(1), not null
#  binding_item_identifier :string
#  binding_call_number     :string
#  binded_at               :datetime
#  manifestation_id        :bigint           not null
#  memo                    :text
#  missing_since           :date
#
