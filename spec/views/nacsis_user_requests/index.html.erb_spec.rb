require 'spec_helper'

describe "nacsis_user_requests/index" do
  before(:each) do
    assign(:nacsis_user_requests, [
      stub_model(NacsisUserRequest,
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
      ),
      stub_model(NacsisUserRequest,
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
      )
    ])
  end

  it "renders a list of nacsis_user_requests" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Subject Heading".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Publisher".to_s, :count => 2
    assert_select "tr>td", :text => "Pub Date".to_s, :count => 2
    assert_select "tr>td", :text => "Physical Description".to_s, :count => 2
    assert_select "tr>td", :text => "Series Title".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Isbn".to_s, :count => 2
    assert_select "tr>td", :text => "Pub Country".to_s, :count => 2
    assert_select "tr>td", :text => "Title Language".to_s, :count => 2
    assert_select "tr>td", :text => "Text Language".to_s, :count => 2
    assert_select "tr>td", :text => "Classmark".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "Ncid".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
