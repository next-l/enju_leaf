class RetentionPeriod < ActiveRecord::Base
  include MasterModel
  attr_accessible :display_name, :name, :note, :position, :non_searchable
  default_scope :order => "position"
  has_many :items
end
