require 'spec_helper'

describe "series_has_manifestations/new" do
  before(:each) do
    assign(:series_has_manifestation, stub_model(SeriesHasManifestation,
      :series_statement_id => 1,
      :manifestation_id => 1,
      :position => 1
    ).as_new_record)
  end

  it "renders new series_has_manifestation form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => series_has_manifestations_path, :method => "post" do
      assert_select "input#series_has_manifestation_series_statement_id", :name => "series_has_manifestation[series_statement_id]"
      assert_select "input#series_has_manifestation_manifestation_id", :name => "series_has_manifestation[manifestation_id]"
    end
  end
end
