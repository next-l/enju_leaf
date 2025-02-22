class CreateType < ApplicationRecord
  include MasterModel
  default_scope { order("create_types.position") }
end

# == Schema Information
#
# Table name: create_types
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
