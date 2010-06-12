class Participate < ActiveRecord::Base
  belongs_to :patron
  belongs_to :event

  acts_as_list :scope => :event_id

  def self.per_page
    10
  end
end
