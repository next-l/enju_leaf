class Accept < ActiveRecord::Base
  belongs_to :basket
  belongs_to :item
  belongs_to :librarian, :class_name => 'User'

  validates_uniqueness_of :item_id, :scope => :basket_id, :on => :create
  validates_presence_of :item_id
  validates_presence_of :basket_id, :on => :create

  before_save :accept!, :on => :create

  attr_accessible :item_identifier
  attr_accessor :item_identifier

  def accept!
    item.circulation_status = CirculationStatus.where(:name => 'Available On Shelf').first
    item.accepted_at = Time.zone.now
    item.save!
  end
end
