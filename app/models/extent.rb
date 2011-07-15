class Extent < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'position'
  has_many :manifestations
end

# == Schema Information
#
# Table name: extents
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#

