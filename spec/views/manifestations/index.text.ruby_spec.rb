require "rails_helper.rb"

describe "manifestations/index.text.ruby" do
  before(:each) do
    manifestation = FactoryBot.create(:manifestation)
    manifestation.items << FactoryBot.create(:item, bookstore_id: 1, budget_type_id: 1, price: 100)
    @manifestations = assign(:manifestations, [manifestation] )
  end

  it "should excludes librarian specific fields" do
    params[:format] = "text"
    render
    csv = CSV.parse(rendered, headers: true, col_sep: "\t")
    expect(csv["bookstore"].compact).to be_empty
  end
end

