class Country < ActiveRecord::Base
  include MasterModel
  default_scope :order => "position"
  has_many :patrons
  #has_many :people
  #has_many :corporate_bodies
  #has_many :families
  has_many :libraries
  has_one :library_group
  
  # If you wish to change the field names for brevity, feel free to enable/modify these.
  # alias_attribute :iso, :alpha_2
  # alias_attribute :iso3, :alpha_3
  # alias_attribute :numeric, :numeric_3
  
  # Validations
  validates_presence_of :alpha_2, :alpha_3, :numeric_3
end
