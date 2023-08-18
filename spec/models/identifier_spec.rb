require 'rails_helper'

describe Identifier do
  # pending "add some examples to (or delete) #{__FILE__}"

end

# == Schema Information
#
# Table name: identifiers
#
#  id                 :bigint           not null, primary key
#  body               :string           not null
#  identifier_type_id :bigint           not null
#  manifestation_id   :bigint
#  primary            :boolean
#  position           :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
