class Numbering < ActiveRecord::Base
  attr_accessible :checkdigit, :display_name, :last_number, :name, :padding, :padding_number, :prefix, :suffix

  validates_presence_of :name, :display_name
  validates_numericality_of :last_number, :allow_blank => true
  validates_numericality_of :padding_number, :allow_blank => true
end
