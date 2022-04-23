require 'rails_helper'

RSpec.describe "withdraws/index", type: :view do
  fixtures :all

  before(:each) do
    FactoryBot.create(:withdraw)
    assign(:withdraws, Withdraw.page(1))
    basket = FactoryBot.create(:basket)
    assign(:basket, basket)
    assign(:withdraw, basket.withdraws.new)
    view.stub(:current_user).and_return(User.friendly.find('enjuadmin'))
  end

  it "renders a list of withdraws" do
    allow(view).to receive(:policy).and_return double(destroy?: true)
    render
    assert_select "tr>td"
  end
end
