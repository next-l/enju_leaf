require 'spec_helper'

describe "nacsis_user_requests/edit" do
  before(:each) do
    @nacsis_user_request = assign(:nacsis_user_request, stub_model(NacsisUserRequest,
      :subject_heading => "MyString",
      :author => "MyText",
      :publisher => "MyString",
      :pub_date => "MyString",
      :physical_description => "MyString",
      :series_title => "MyString",
      :note => "MyText",
      :isbn => "MyString",
      :pub_country => "MyString",
      :title_language => "MyString",
      :text_language => "MyString",
      :classmark => "MyString",
      :author_heading => "MyText",
      :subject => "MyText",
      :ncid => "MyString",
      :user_id => 1,
      :request_type => 1,
      :state => 1,
      :user_note => "MyText",
      :librarian_note => "MyText"
    ))
  end

  it "renders the edit nacsis_user_request form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", nacsis_user_request_path(@nacsis_user_request), "post" do
      assert_select "input#nacsis_user_request_subject_heading[name=?]", "nacsis_user_request[subject_heading]"
      assert_select "textarea#nacsis_user_request_author[name=?]", "nacsis_user_request[author]"
      assert_select "input#nacsis_user_request_publisher[name=?]", "nacsis_user_request[publisher]"
      assert_select "input#nacsis_user_request_pub_date[name=?]", "nacsis_user_request[pub_date]"
      assert_select "input#nacsis_user_request_physical_description[name=?]", "nacsis_user_request[physical_description]"
      assert_select "input#nacsis_user_request_series_title[name=?]", "nacsis_user_request[series_title]"
      assert_select "textarea#nacsis_user_request_note[name=?]", "nacsis_user_request[note]"
      assert_select "input#nacsis_user_request_isbn[name=?]", "nacsis_user_request[isbn]"
      assert_select "input#nacsis_user_request_pub_country[name=?]", "nacsis_user_request[pub_country]"
      assert_select "input#nacsis_user_request_title_language[name=?]", "nacsis_user_request[title_language]"
      assert_select "input#nacsis_user_request_text_language[name=?]", "nacsis_user_request[text_language]"
      assert_select "input#nacsis_user_request_classmark[name=?]", "nacsis_user_request[classmark]"
      assert_select "textarea#nacsis_user_request_author_heading[name=?]", "nacsis_user_request[author_heading]"
      assert_select "textarea#nacsis_user_request_subject[name=?]", "nacsis_user_request[subject]"
      assert_select "input#nacsis_user_request_ncid[name=?]", "nacsis_user_request[ncid]"
      assert_select "input#nacsis_user_request_user_id[name=?]", "nacsis_user_request[user_id]"
      assert_select "input#nacsis_user_request_request_type[name=?]", "nacsis_user_request[request_type]"
      assert_select "input#nacsis_user_request_state[name=?]", "nacsis_user_request[state]"
      assert_select "textarea#nacsis_user_request_user_note[name=?]", "nacsis_user_request[user_note]"
      assert_select "textarea#nacsis_user_request_librarian_note[name=?]", "nacsis_user_request[librarian_note]"
    end
  end
end
