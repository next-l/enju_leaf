require 'rails_helper'

describe "checkouts/edit" do
  fixtures :checkouts, :users, :user_has_roles, :roles

  before(:each) do
    @checkout = assign(:checkout, checkouts(:checkout_00001))
    assign(:new_due_date, 1.day.from_now)
    assign(:library_group, LibraryGroup.site_config)
    view.stub(:current_user).and_return(User.find_by(username: 'enjuadmin'))
  end

  it "renders the edit checkout form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", action: checkouts_path(@checkout), method: "post" do
      assert_select "input#checkout_user_id", name: "checkout[user_id]"
      assert_select "input#checkout_item_id", name: "checkout[item_id]"
      assert_select "input#checkout_due_date", name: "checkout[due_date]"
    end
  end
end
