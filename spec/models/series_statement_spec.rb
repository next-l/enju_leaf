require 'rails_helper'

describe SeriesStatement do
  fixtures :all

  it "should create manifestation" do
    series_statement = FactoryBot.create(:series_statement)
    series_statement.root_manifestation.should be_nil
  end
end
