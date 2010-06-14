class ClassificationType < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'position'
  has_many :classifications
  validates_presence_of :name, :display_name
  before_validation :set_display_name, :on => :create
  acts_as_list
end
