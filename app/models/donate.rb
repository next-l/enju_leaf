class Donate < ActiveRecord::Base
  attr_accessible :patron_id, :item_id
  belongs_to :patron, :validate => true
  belongs_to :item, :validate => true
  validates_associated :patron, :item
  validates_presence_of :patron, :item

  def self.per_page
    10
  end
end

# == Schema Information
#
# Table name: donates
#
#  id         :integer         not null, primary key
#  patron_id  :integer         not null
#  item_id    :integer         not null
#  created_at :datetime
#  updated_at :datetime
#

