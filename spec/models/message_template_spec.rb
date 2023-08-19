require 'rails_helper'

describe MessageTemplate do
  # pending "add some examples to (or delete) #{__FILE__}"
end

# == Schema Information
#
# Table name: message_templates
#
#  id         :bigint           not null, primary key
#  status     :string           not null
#  title      :text             not null
#  body       :text             not null
#  position   :integer
#  locale     :string           default("en")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
