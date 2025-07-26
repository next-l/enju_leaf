class Inventory < ApplicationRecord
  belongs_to :item, optional: true
  belongs_to :inventory_file

  validates :item_identifier, :current_shelf_name, presence: true
  validates :item_id, :item_identifier, uniqueness: { scope: :inventory_file_id }

  paginates_per 10

  def to_hash
    {
      created_at: created_at,
      identifier: item_identifier,
      item_identifier: item.try(:item_identifier),
      current_shelf: current_shelf_name,
      shelf: item.try(:shelf),
      call_number: item.try(:call_number),
      circulation_status: item.try(:circulation_status).try(:name),
      title: item.try(:manifestation).try(:original_title),
      extent: item.try(:manifestation).try(:extent)
    }
  end

  def lost
    item.circulation_status = CirculationStatus.find_by(name: "Missing")
  end

  def found
    if item.rended?
      item.circulation_status = CirculationStatus.find_by(name: "On Loan")
    else
      item.circulation_status = CirculationStatus.find_by(name: "Available On Shelf")
    end
  end
end

# ## Schema Information
#
# Table name: `inventories`
#
# ### Columns
#
# Name                      | Type               | Attributes
# ------------------------- | ------------------ | ---------------------------
# **`id`**                  | `bigint`           | `not null, primary key`
# **`current_shelf_name`**  | `string`           |
# **`item_identifier`**     | `string`           |
# **`note`**                | `text`             |
# **`created_at`**          | `datetime`         | `not null`
# **`updated_at`**          | `datetime`         | `not null`
# **`inventory_file_id`**   | `bigint`           |
# **`item_id`**             | `bigint`           |
#
# ### Indexes
#
# * `index_inventories_on_current_shelf_name`:
#     * **`current_shelf_name`**
# * `index_inventories_on_inventory_file_id`:
#     * **`inventory_file_id`**
# * `index_inventories_on_item_id`:
#     * **`item_id`**
# * `index_inventories_on_item_identifier`:
#     * **`item_identifier`**
#
