class PatronType < ActiveRecord::Base
  include MasterModel
  default_scope :order => "patron_types.position"
  has_many :patrons
end

# == Schema Information
#
# Table name: patron_types
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#

