class Wareki < ActiveRecord::Base
  attr_accessible :display_name, :note, :short_name, :year_from, :year_to

  validates :display_name, :presence => true
  validates :short_name, :presence => true
  validates :year_from, :numericality => {:only_integer => true}, :allow_blank => false
  validates :year_to, :numericality => {:only_integer => true}, :allow_blank => true
end
