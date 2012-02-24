require 'spec_helper'

describe "series_has_manifestations/show" do
  before(:each) do
    @series_has_manifestation = assign(:series_has_manifestation, stub_model(SeriesHasManifestation,
      :series_statement_id => 1,
      :manifestation_id => 1,
      :position => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
  end
end
