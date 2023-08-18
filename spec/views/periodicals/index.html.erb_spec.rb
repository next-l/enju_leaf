require 'rails_helper'

RSpec.describe "periodicals/index", type: :view do
  fixtures :all

  before(:each) do
    assign(:periodicals, 
      Periodical.page(1)
    )
  end

  it "renders a list of periodicals" do
    allow(view).to receive(:policy).and_return double(update?: true, destroy?: true)
    render
    cell_selector = Rails::VERSION::STRING >= '7' ? 'div>p' : 'tr>td'
  end
end
