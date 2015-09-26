require 'rails_helper'

describe "user_import_results/index" do
  fixtures :all

  before(:each) do
    assign(:user_import_results, UserImportResult.page(1))
    admin = User.find('enjuadmin')
    view.stub(:current_user).and_return(admin)
    @ability = EnjuLeaf::Ability.new(admin, '0.0.0.0')
    @ability.extend(CanCan::Ability)
    controller.stub(:current_ability) { @ability }
  end

  it "renders a list of user_import_results" do
    render
    expect(rendered).to match /MyString/
  end
end
