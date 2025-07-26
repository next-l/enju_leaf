require 'rails_helper'

RSpec.describe "periodicals/new", type: :view do
  before(:each) do
    assign(:periodical, Periodical.new())
  end

  it "renders new periodical form" do
    render

    assert_select "form[action=?][method=?]", periodicals_path, "post" do
    end
  end
end
