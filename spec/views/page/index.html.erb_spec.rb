require 'rails_helper'

describe "page/index" do
  fixtures :all

  before(:each) do
    allow(view).to receive(:current_user).and_return(User.find_by(username: 'enjuadmin'))
    assign(:tags, Tag.all)
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/Catalog search/)
  end
end
