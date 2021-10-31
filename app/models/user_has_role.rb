class UserHasRole < ApplicationRecord
  belongs_to :user
  belongs_to :role
  accepts_nested_attributes_for :role
end

# == Schema Information
#
# Table name: user_has_roles
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  role_id    :integer          not null
#  created_at :datetime
#  updated_at :datetime
#
