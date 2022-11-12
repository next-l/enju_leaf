class InventoryFile < ApplicationRecord
  has_many :inventories, dependent: :destroy
  has_many :items, through: :inventories
  belongs_to :user
  belongs_to :shelf, optional: true

  if ENV['ENJU_STORAGE'] == 's3'
    has_attached_file :inventory, storage: :s3,
                                  s3_credentials: {
        access_key: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
        bucket: ENV['S3_BUCKET_NAME']
      },
                                  s3_permissions: :private
  else
    has_attached_file :inventory,
      path: ":rails_root/private/system/:class/:attachment/:id_partition/:style/:filename"
  end
  validates_attachment_content_type :inventory, content_type: ['text/csv', 'text/plain', 'text/tab-separated-values']
  validates_attachment_presence :inventory, on: :create
  attr_accessor :library_id

  paginates_per 10

  def import
    reload
    file = File.open(inventory.path)
    reader = file.read
    reader.split.each do |row|
      identifier = row.to_s.strip
      item = Item.find_by(item_identifier: identifier)
      next unless item
      next if self.items.where(id: item.id).select('items.id').first

      Inventory.create(
        inventory_file: self,
        item: item,
        current_shelf_name: shelf.name,
        item_identifier: identifier
      )
    end
    file.close
    true
  end

  def export(col_sep: "\t")
    file = Tempfile.create('inventory_file') do |f|
      inventories.each do |inventory|
        f.write inventory.to_hash.values.to_csv(col_sep)
      end

      f.rewind
      f.read
    end

    file
  end

  def missing_items
    Item.where(Inventory.where('items.id = inventories.item_id AND inventories.inventory_file_id = ?', id).exists.not)
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
#  filename               :string
#  content_type           :string
#  size                   :integer
#  user_id                :integer
#  note                   :text
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  inventory_file_name    :string
#  inventory_content_type :string
#  inventory_file_size    :integer
#  inventory_updated_at   :datetime
#  inventory_fingerprint  :string
#  shelf_id               :bigint
#
