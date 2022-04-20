require 'rails_helper'

describe EnjuBiblio::ApplicationHelper do
  fixtures :all

  it "should render form_icon if carrier_type is nil" do
    expect(helper.form_icon(nil)).to match /src=\"\/assets\/icons\/help-/
  end

  it "should render form_icon if carrier_type's attachment is blank " do
    expect(helper.form_icon(FactoryBot.create(:carrier_type))).to match /src=\"\/assets\/icons\/help-/
  end
end
