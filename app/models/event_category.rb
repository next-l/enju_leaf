class EventCategory < ActiveRecord::Base
  include MasterModel
  has_many :events

  def self.per_page
    10
  end
end
