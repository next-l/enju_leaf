require 'rails_helper'

RSpec.describe "withdraws/edit", type: :view do
  before(:each) do
    @withdraw = assign(:withdraw, FactoryBot.create(:withdraw))
  end

  it "renders the edit withdraw form" do
    render

    assert_select "form[action=?][method=?]", withdraw_path(@withdraw), "post" do
    end
  end
end
