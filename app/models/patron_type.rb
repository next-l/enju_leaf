class PatronType < ActiveRecord::Base
  include MasterModel
  default_scope :order => "patron_types.position"
  has_many :patrons
end
