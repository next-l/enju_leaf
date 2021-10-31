class Inventory < ApplicationRecord
  belongs_to :item, optional: true
  belongs_to :inventory_file

  validates :item_identifier, :current_shelf_name, presence: true
  validates :item_id, :item_identifier, uniqueness: {scope: :inventory_file_id}

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
    item.circulation_status = CirculationStatus.find_by(name: 'Missing')
  end

  def found
    if item.rended?
      item.circulation_status = CirculationStatus.find_by(name: 'On Loan')
    else
      item.circulation_status = CirculationStatus.find_by(name: 'Available On Shelf')
    end
  end
end

# == Schema Information
#
# Table name: inventories
#
#  id                 :integer          not null, primary key
#  item_id            :integer
#  inventory_file_id  :integer
#  note               :text
#  created_at         :datetime
#  updated_at         :datetime
#  item_identifier    :string
#  current_shelf_name :string
#
