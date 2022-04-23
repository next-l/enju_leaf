require 'rails_helper'

describe "manifestations/show" do
  fixtures :all

  before(:each) do
    assign(:manifestation, FactoryBot.create(:manifestation))
    assign(:library_group, library_groups(:one))
    allow(view).to receive(:policy).and_return double(create?: false, udpate?: false, destroy?: false)
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
  end

  describe "identifier_link" do
    it "renders a link to CiNii Books" do
      assign(:manifestation, manifestations(:manifestation_00217))
      render
      rendered.should include '<a href="https://ci.nii.ac.jp/ncid/BN15603730">BN15603730</a>'
    end
  end

  describe "when logged in as Librarian" do
    before(:each) do
      user = assign(:profile, FactoryBot.create(:librarian))
      view.stub(:current_user).and_return(user)
      allow(view).to receive(:policy).and_return double(create?: true, update?: true, destroy?: true)
    end

    it "should have an ISBD separator for extent and dimensions" do
      assign(:manifestation, FactoryBot.create(:manifestation, extent: "extent value", dimensions: "dimensions value"))
      render
      expect(rendered).to match /\s+;\s+/
    end
  end

  describe "when logged in as User" do
    before(:each) do
      user = assign(:profile, FactoryBot.create(:user))
      view.stub(:current_user).and_return(user)
    end
    it "should have an ISBD separator for extent and dimensions" do
      assign(:manifestation, FactoryBot.create(:manifestation, extent: "extent value", dimensions: "dimensions value"))
      render
      expect(rendered).to match /\s+;\s+/
    end
  end
end
