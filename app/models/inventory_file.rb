class InventoryFile < ApplicationRecord
  has_many :inventories, dependent: :destroy
  has_many :items, through: :inventories
  belongs_to :user
  belongs_to :shelf, optional: true

  has_one_attached :attachment
  attr_accessor :library_id

  paginates_per 10

  def import
    reload
    reader = attachment.download
    reader.split.each do |row|
      identifier = row.to_s.strip
      item = Item.find_by(item_identifier: identifier)
      next unless item
      next if self.items.where(id: item.id).select("items.id").first

      Inventory.create(
        inventory_file: self,
        item: item,
        current_shelf_name: shelf.name,
        item_identifier: identifier
      )
    end

    true
  end

  def export(col_sep: "\t")
    file = Tempfile.create("inventory_file") do |f|
      inventories.each do |inventory|
        f.write inventory.to_hash.values.to_csv(col_sep)
      end

      f.rewind
      f.read
    end

    file
  end

  def missing_items
    Item.where(Inventory.where("items.id = inventories.item_id AND inventories.inventory_file_id = ?", id).exists.not)
  end

  def found_items
    items
  end
end

# == Schema Information
#
# Table name: inventory_files
#
#  id                     :bigint           not null, primary key
#  inventory_content_type :string
#  inventory_file_name    :string
#  inventory_file_size    :integer
#  inventory_fingerprint  :string
#  inventory_updated_at   :datetime
#  note                   :text
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  shelf_id               :bigint
#  user_id                :bigint
#
# Indexes
#
#  index_inventory_files_on_shelf_id  (shelf_id)
#  index_inventory_files_on_user_id   (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (shelf_id => shelves.id)
#  fk_rails_...  (user_id => users.id)
#
