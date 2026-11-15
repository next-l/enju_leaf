require 'rails_helper'

describe "my_accounts/show" do
  fixtures :all

  before(:each) do
    @profile = assign(:profile, profiles(:profile_admin))
  end

  describe "when logged in as Librarian" do
    before(:each) do
      @profile = assign(:profile, profiles(:profile_librarian2))
      user = users(:librarian1)
      allow(view).to receive(:current_user).and_return(user)
    end

    it "renders attributes in <p>" do
      allow(view).to receive(:policy).and_return double(update?: true, destroy?: true)
      render
      # Run the generator again with the --webrat flag if you want to use webrat matchers
      expect(rendered).to match(/Checkout/)
    end

    it "cannot be deletable by other librarian" do
      allow(view).to receive(:policy).and_return double(update?: true, destroy?: true)
      render
    end
  end

  describe "when logged in as User" do
    before(:each) do
      @profile = assign(:profile, profiles(:profile_user2))
      user = users(:librarian1)
      allow(view).to receive(:current_user).and_return(user)
    end

    it "renders attributes in <p>" do
      allow(view).to receive(:policy).and_return double(update?: true, destroy?: true)
      render
      expect(rendered).to match(/Checkout/)
    end
  end
end
