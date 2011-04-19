class Participate < ActiveRecord::Base
  belongs_to :patron
  belongs_to :event

  acts_as_list :scope => :event_id

  paginates_per 10
end
