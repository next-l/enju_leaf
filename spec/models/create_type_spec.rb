require 'rails_helper'

describe CreateType do
  it 'should create create_type' do
    FactoryBot.create(:create_type)
  end
end

# == Schema Information
#
# Table name: create_types
#
#  id           :bigint           not null, primary key
#  display_name :text
#  name         :string           not null
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_create_types_on_lower_name  (lower((name)::text)) UNIQUE
#
