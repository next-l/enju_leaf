class Frequency < ActiveRecord::Base
  attr_accessible :name, :display_name, :note, :freq_string, :position, :nii_code

  include MasterModel
  default_scope :order => "position"
  has_many :manifestations
end

# == Schema Information
#
# Table name: frequencies
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#

