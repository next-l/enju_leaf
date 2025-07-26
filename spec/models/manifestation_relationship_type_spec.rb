require 'rails_helper'

describe ManifestationRelationshipType do
  # pending "add some examples to (or delete) #{__FILE__}"

end

# == Schema Information
#
# Table name: manifestation_relationship_types
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
#  index_manifestation_relationship_types_on_lower_name  (lower((name)::text)) UNIQUE
#
