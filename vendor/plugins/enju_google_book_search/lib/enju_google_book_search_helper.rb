module EnjuGoogleBookSearchHelper
  def google_book_search_preview(isbn)
    render :partial => 'manifestations/google_book_search', :locals => {:isbn => isbn}
  end
end
