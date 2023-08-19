require 'rails_helper'

RSpec.describe Periodical, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

# == Schema Information
#
# Table name: periodicals
#
#  id               :bigint           not null, primary key
#  original_title   :text             not null
#  manifestation_id :bigint           not null
#  frequency_id     :bigint           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
