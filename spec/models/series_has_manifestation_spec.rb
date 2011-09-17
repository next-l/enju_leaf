require 'spec_helper'

describe SeriesHasManifestation do
  it "should reindex" do
    series_has_manifestation = FactoryGirl.create(:series_has_manifestation)
    series_has_manifestation.reindex.should be_true
  end
end

# == Schema Information
#
# Table name: series_has_manifestations
#
#  id                  :integer         not null, primary key
#  series_statement_id :integer
#  manifestation_id    :integer
#  position            :integer
#  created_at          :datetime
#  updated_at          :datetime
#

