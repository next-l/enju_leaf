class Donate < ActiveRecord::Base
  belongs_to :patron, :validate => true
  belongs_to :item, :validate => true
  validates_associated :patron, :item
  validates_presence_of :patron, :item

  paginates_per 10
end
