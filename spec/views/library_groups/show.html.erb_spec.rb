require 'rails_helper'

describe "library_groups/show" do
  before(:each) do
    @library_group = LibraryGroup.site_config
    view.stub(:current_user).and_return(User.friendly.find('enjuadmin'))
  end

  it "renders attributes in <p>" do
    allow(view).to receive(:policy).and_return double(update?: true)
    render
  end
end
