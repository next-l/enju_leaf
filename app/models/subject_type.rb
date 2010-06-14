class SubjectType < ActiveRecord::Base
  include MasterModel
  default_scope :order => "position"
  has_many :subjects

  validates_presence_of :name, :display_name
  validates_uniqueness_of :name
  before_validation :set_display_name, :on => :create

  acts_as_list
end
