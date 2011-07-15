class Inventory < ActiveRecord::Base
  belongs_to :item
  belongs_to :inventory_file

  validates_associated :item, :inventory_file
  validates_presence_of :item, :inventory_file
  validates_uniqueness_of :item_id, :scope => :inventory_file_id

  def self.per_page
    10
  end
end

# == Schema Information
#
# Table name: inventories
#
#  id                :integer         not null, primary key
#  item_id           :integer
#  inventory_file_id :integer
#  note              :text
#  created_at        :datetime
#  updated_at        :datetime
#

