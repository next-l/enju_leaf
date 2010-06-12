class ClassificationType < ActiveRecord::Base
  default_scope :order => 'position'
  has_many :classifications
  validates_presence_of :name, :display_name
  before_validation :set_display_name, :on => :create

  acts_as_list

  def set_display_name
    self.display_name = self.name if display_name.blank?
  end
end
