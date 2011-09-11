require 'spec_helper'

describe SeriesHasManifestation do
  it "should reindex" do
    series_has_manifestation = FactoryGirl.create(:series_has_manifestation)
    series_has_manifestation.reindex.should be_true
  end
end
