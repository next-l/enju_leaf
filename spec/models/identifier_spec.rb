require 'rails_helper'

describe Identifier do
  # pending "add some examples to (or delete) #{__FILE__}"

end

# == Schema Information
#
# Table name: identifiers
#
#  id                 :integer          not null, primary key
#  body               :string           not null
#  identifier_type_id :integer          not null
#  manifestation_id   :integer
#  primary            :boolean
#  position           :integer
#  created_at         :datetime
#  updated_at         :datetime
#
