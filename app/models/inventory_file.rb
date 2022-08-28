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
    if ENV['ENJU_STORAGE'] == 's3'
      body = Faraday.get(inventory.expiring_url(10)).body.force_encoding('UTF-8')
    else
      body = File.open(inventory.path).read
    end

    CSV.parse(body, headers: true, col_sep: "\t") do |row|
      # 電子書籍を除外
      next if row['shelf'] == 'web'
      item_identifier = row['item_identifier'].to_s.strip
      next if item_identifier.blank?

      Item.transaction do
        item = Item.find_by(item_identifier: item_identifier)
        Inventory.create(
          inventory_file: self,
          item: item,
          current_shelf_name: shelf.name,
          item_identifier: item_identifier
        )

        next unless item

        # 配架場所の変更を反映
        unless row['current_shelf'] == row['shelf']
          unless row['current_shelf'] == '-' or row['current_shelf'].blank?
            shelf = Shelf.find_by(name: row['current_shelf'])
            if item && shelf
              item.update!(shelf: Shelf.find_by(name: row['current_shelf']))
              Rails.logger.info "Inventory: #{item.item_identifier}: shelf updated to #{shelf.name}"
            end
          end
        end
        next

        case row['circulation_status']
        when 'On Loan'
          # 書架にないと報告されたが、確認したら貸出中の場合、不明日を削除
          if item.missing_since.present?
            item.update!(missing_since: nil)
            Rails.logger.info "Inventory: #{row['item_identifier']}: wrong report (rent)"
          end
        when 'Available On Shelf'
          # 書架にないと報告されたが、確認したら書架にあった本を「利用可能」に変更
          if row['current_shelf'] == '-' or row['current_shelf'].blank?
            if item.missing_since.present? && !item.rent?
              item.update!(missing_since: nil, circulation_status: CirculationStatus.find_by(name: row['circulation_status']))
              Rails.logger.info "Inventory: #{row['item_identifier']}: wrong report (on shelf)"
            end
          end

          # 発見された不明本の状態を変更
          unless row['current_shelf'] == '-' or row['current_shelf'].blank?
            if row['found_at'].present?
              if item.rent?
                item.update!(missing_since: nil)
              else
                item.update!(
                  missing_since: nil,
                  circulation_status: CirculationStatus.find_by(name: row['circulation_status'])
                )
              end
              Rails.logger.info "Inventory: #{row['item_identifier']}: changed status to found"
            end
          end

          if item.circulation_status.name == 'In Process'
            item.update!(circulation_status: CirculationStatus.find_by(name: 'Available On Shelf'))
            Rails.logger.info "Inventory: #{row['item_identifier']}: changed status to available"
          end
        when 'Missing'
          item.circulation_status = CirculationStatus.find_by(name: 'Missing') unless item.circulation_status == 'Missing'
          if row['missing_since'].blank?
            item.update!(missing_since: Date.today)
            Rails.logger.info "Inventory: #{row['item_identifier']}: changed status to missing"
          else
            item.update!(missing_since: Date.parse(row['missing_since']))
            Rails.logger.info "Inventory: #{row['item_identifier']}: changed status to missing"
          end
        end
      end
    end
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
#  id                     :integer          not null, primary key
#  filename               :string
#  content_type           :string
#  size                   :integer
#  user_id                :integer
#  note                   :text
#  created_at             :datetime
#  updated_at             :datetime
#  inventory_file_name    :string
#  inventory_content_type :string
#  inventory_file_size    :integer
#  inventory_updated_at   :datetime
#  inventory_fingerprint  :string
#  shelf_id               :bigint
#
