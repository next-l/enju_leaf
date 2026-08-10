require 'rails_helper'

RSpec.describe "periodicals/edit", type: :view do
  fixtures :all

  let(:periodical) {
    periodicals(:periodical_00001)
  }

  before(:each) do
    assign(:periodical, periodical)
  end

  it "renders the edit periodical form" do
    render

    assert_select "form[action=?][method=?]", periodical_path(periodical), "post" do
    end
  end
end
