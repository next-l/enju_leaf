class PatronType < ActiveRecord::Base
  include MasterModel
  has_many :patrons
end
