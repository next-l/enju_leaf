class ContentType < ActiveRecord::Base
  attr_accessible :name, :display_name, :note
  include MasterModel
  default_scope :order => "content_types.position"
  has_many :manifestations
end

# == Schema Information
#
# Table name: content_types
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#

