require 'rails_helper'

describe "page/configuration" do
  fixtures :all

  before(:each) do
    allow(view).to receive(:current_user).and_return(User.find_by(username: 'enjuadmin'))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/System configuration/)
  end
end
