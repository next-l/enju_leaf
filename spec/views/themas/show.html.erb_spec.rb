require 'spec_helper'

describe "themas/show" do
  before(:each) do
    @thema = assign(:thema, stub_model(Thema,
      :name => "Name",
      :description => "MyText",
      :publish => 1,
      :note => "MyText",
      :position => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/MyText/)
    rendered.should match(/1/)
    rendered.should match(/MyText/)
    rendered.should match(/2/)
  end
end
