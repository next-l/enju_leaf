require 'rails_helper'

describe "page/opensearch" do
  fixtures :all

  before(:each) do
    assign(:library_group, LibraryGroup.site_config)
    allow(view).to receive(:current_user).and_return(User.find_by(username: 'enjuadmin'))
  end

  it "renders the XML template" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/Library Catalog/)
  end
end
