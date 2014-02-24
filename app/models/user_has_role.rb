# == Schema Information
#
# Table name: user_has_roles
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  role_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserHasRole < ActiveRecord::Base
  #attr_accessible :user_id, :role_id
  #attr_accessible :user_id, :role_id, :as => :admin
  belongs_to :user
  belongs_to :role
  accepts_nested_attributes_for :role

#  validates_uniqueness_of :role_id, :scope => :user_id
#  validates_presence_of :role_id, :user_id
end
