class Donate < ActiveRecord::Base
  belongs_to :patron, :validate => true
  belongs_to :item, :validate => true
  validates_associated :patron, :item
  validates_presence_of :patron, :item

  def self.per_page
    10
  end
end
