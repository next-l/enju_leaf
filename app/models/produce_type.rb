class ProduceType < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'position'
end

# == Schema Information
#
# Table name: produce_types
#
#  id           :integer         not null, primary key
#  name         :string(255)
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#

