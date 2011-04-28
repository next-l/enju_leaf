class EventCategory < ActiveRecord::Base
  include MasterModel
  default_scope :order => "position"
  has_many :events

  def self.per_page
    10
  end
end
