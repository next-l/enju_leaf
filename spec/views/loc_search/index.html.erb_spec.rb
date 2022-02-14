require "spec_helper.rb"

describe "loc_search/index" do
  describe "loc search menu" do
    it "should reflect query params for views", vcr: true do
      params[:query] = "test"
      assign(:query, "test")
      books = LocSearch.search(params[:query])
      assign(:books, Kaminari.paginate_array(books[:items], total_count: books[:total_entries]).page(1).per(10))
      render
      expect(rendered).to include "https://catalog.loc.gov/vwebv/search?searchArg=test&amp;searchCode=GKEY%5E*&amp;searchType=0"
    end
  end
end
