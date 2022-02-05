require "spec_helper"

describe "cinii_books/index" do
  describe "cinii books search menu" do
    it "should reflect query params for views", vcr: true do
      params[:query] = "test"
      assign(:query, "test")
      books = CiniiBook.search(params[:query])
      assign(:books, Kaminari.paginate_array(books[:items], total_count: books[:total_entries]).page(1).per(10))
      render
      expect(rendered).to include "https://ci.nii.ac.jp/books/search?q=test"
    end
  end
end
