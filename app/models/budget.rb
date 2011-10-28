class Budget < ActiveRecord::Base
  validates_presence_of :library_id, :term_id
  has_one :library
  has_one :term
end

