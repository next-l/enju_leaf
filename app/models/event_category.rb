class EventCategory < ActiveRecord::Base
  include MasterModel
  default_scope :order => "position"
  has_many :events

  paginates_per 10
end
