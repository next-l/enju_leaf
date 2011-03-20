class Inventory < ActiveRecord::Base
  belongs_to :item
  belongs_to :inventory_file

  validates_associated :item, :inventory_file
  validates_presence_of :item, :inventory_file
  validates_uniqueness_of :item_id, :scope => :inventory_file_id

  paginates_per 10
end
