require 'spec_helper'

describe "nacsis_user_requests/show" do
  before(:each) do
    @nacsis_user_request = assign(:nacsis_user_request, stub_model(NacsisUserRequest,
      :subject_heading => "Subject Heading",
      :author => "MyText",
      :publisher => "Publisher",
      :pub_date => "Pub Date",
      :physical_description => "Physical Description",
      :series_title => "Series Title",
      :note => "MyText",
      :isbn => "Isbn",
      :pub_country => "Pub Country",
      :title_language => "Title Language",
      :text_language => "Text Language",
      :classmark => "Classmark",
      :author_heading => "MyText",
      :subject => "MyText",
      :ncid => "Ncid",
      :user_id => 1,
      :request_type => 2,
      :state => 3,
      :user_note => "MyText",
      :librarian_note => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Subject Heading/)
    rendered.should match(/MyText/)
    rendered.should match(/Publisher/)
    rendered.should match(/Pub Date/)
    rendered.should match(/Physical Description/)
    rendered.should match(/Series Title/)
    rendered.should match(/MyText/)
    rendered.should match(/Isbn/)
    rendered.should match(/Pub Country/)
    rendered.should match(/Title Language/)
    rendered.should match(/Text Language/)
    rendered.should match(/Classmark/)
    rendered.should match(/MyText/)
    rendered.should match(/MyText/)
    rendered.should match(/Ncid/)
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/3/)
    rendered.should match(/MyText/)
    rendered.should match(/MyText/)
  end
end
