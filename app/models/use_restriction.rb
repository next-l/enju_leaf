class UseRestriction < ActiveRecord::Base
  default_scope :order => 'position'
  has_many :item_has_use_restrictions
  has_many :items, :through => :item_has_use_restrictions

  validates_presence_of :name, :display_name
  before_validation :set_display_name, :on => :create

  acts_as_list

  def set_display_name
    self.display_name = self.name if display_name.blank?
  end
end
