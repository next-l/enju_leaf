require 'rails_helper'

describe FormOfWork do
  # pending "add some examples to (or delete) #{__FILE__}"

end

# == Schema Information
#
# Table name: form_of_works
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
#  index_form_of_works_on_lower_name  (lower((name)::text)) UNIQUE
#
