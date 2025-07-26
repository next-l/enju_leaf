require 'rails_helper'

describe Frequency do
  fixtures :frequencies

  it "should should have display_name" do
    frequencies(:frequency_00001).display_name.should_not be_nil
  end
end

# == Schema Information
#
# Table name: frequencies
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
#  index_frequencies_on_lower_name  (lower((name)::text)) UNIQUE
#
