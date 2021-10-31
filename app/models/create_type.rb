class CreateType < ApplicationRecord
  include MasterModel
  default_scope { order('create_types.position') }
end

# == Schema Information
#
# Table name: create_types
#
#  id           :integer          not null, primary key
#  name         :string
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#
