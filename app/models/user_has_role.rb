class UserHasRole < ApplicationRecord
  belongs_to :user
  belongs_to :role
  accepts_nested_attributes_for :role
end

# == Schema Information
#
# Table name: user_has_roles
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  role_id    :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
