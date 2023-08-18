require 'rails_helper'

RSpec.describe "periodicals/show", type: :view do
  fixtures :all

  before(:each) do
    assign(:periodical, periodicals(:periodical_00001))
  end

  it "renders attributes in <p>" do
    render
  end
end
