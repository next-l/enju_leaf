require 'rails_helper'

RSpec.describe "periodicals/show", type: :view do
  before(:each) do
    assign(:periodical, Periodical.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
