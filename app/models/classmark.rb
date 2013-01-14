class Classmark < ActiveRecord::Base
  attr_accessible :display_name, :name

  validates_uniqueness_of :name
  validates_presence_of :name, :display_name

  paginates_per 10

end
