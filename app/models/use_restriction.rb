class UseRestriction < ActiveRecord::Base
  attr_accessible :name, :display_name, :note
  include MasterModel
  default_scope :order => 'position'
  scope :available, where(:name => ['Not For Loan', 'Limited Circulation, Normal Loan Period'])
  has_many :item_has_use_restrictions
  has_many :items, :through => :item_has_use_restrictions
  attr_protected :name
end

# == Schema Information
#
# Table name: use_restrictions
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#

