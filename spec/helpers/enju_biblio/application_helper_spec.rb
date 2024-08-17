require 'rails_helper'

describe EnjuBiblio::ApplicationHelper do
  fixtures :all

  it "should render form_icon if carrier_type is nil" do
    expect(helper.form_icon(nil)).to match /src=\"\/assets\/icons\/help-/
  end

  it "should render form_icon if carrier_type's attachment is blank" do
    expect(helper.form_icon(FactoryBot.create(:carrier_type))).to match /src=\"\/assets\/icons\/help-/
  end

  it "should link to old NDL search if iss_itemno ends with '-00'" do
    expect(
      helper.identifier_link(
        FactoryBot.build(
          :identifier,
          body: 'R100000039-I001413988-00',
          identifier_type: IdentifierType.find_by(name: 'iss_itemno')
        )
      )
    ).to eq "<a href=\"https://iss.ndl.go.jp/books/R100000039-I001413988-00\">R100000039-I001413988-00</a>"
  end

  it "should link to new NDL search if iss_itemno doesn't end with '-00'" do
    expect(
      helper.identifier_link(
        FactoryBot.build(
          :identifier,
          body: 'R100000039-I001413988',
          identifier_type: IdentifierType.find_by(name: 'iss_itemno')
        )
      )
    ).to eq "<a href=\"https://ndlsearch.ndl.go.jp/books/R100000039-I001413988\">R100000039-I001413988</a>"
  end
end
