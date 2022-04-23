require 'rails_helper'

RSpec.describe "withdraws/show", type: :view do
  before(:each) do
    @withdraw = assign(:withdraw, FactoryBot.create(:withdraw))
  end

  it "renders attributes in <p>" do
    render
  end
end
