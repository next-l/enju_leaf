class CirculationStatus < ActiveRecord::Base
  default_scope :order => "position"
  scope :available_for_checkout, :conditions => {:name => ['Available On Shelf']}
  has_many :items

  validates_presence_of :name, :display_name
  validates_uniqueness_of :name
  before_validation :set_display_name, :on => :create

  acts_as_list

  def set_display_name
    self.display_name = self.name if display_name.blank?
  end

end
