require 'rails_helper'

describe "library_groups/edit" do
  fixtures :all

  before(:each) do
    @library_group = LibraryGroup.site_config
    @available_languages = Language.where(iso_639_1: I18n.available_locales.map{|l| l.to_s})
    @countries = Country.all
  end

  it "renders selector for multilpe book jacket sources." do
    render
    expect(rendered).to have_css "select#library_group_book_jacket_source"
    expect(rendered).to have_css "select#library_group_book_jacket_source option", minimum: 2
    expect(rendered).to have_css 'select#library_group_book_jacket_source option[value="google"]'
    expect(rendered).to have_css 'select#library_group_book_jacket_source option[value="openbd"]'
    expect(rendered).to have_css 'select#library_group_book_jacket_source option[value="hanmotocom"]'
  end

  it "renders color forms." do
    render
    expect(rendered).to have_css "input#library_group_colors_attributes_0_code"
    expect(rendered).not_to have_css "input#library_group_colors_attributes_0__destroy", visible: false
    expect(rendered).not_to have_xpath '//a[@data-association="color" and @class="add_fields"]'
  end
end
