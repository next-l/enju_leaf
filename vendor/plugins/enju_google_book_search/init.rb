require 'enju_google_book_search'
ActiveRecord::Base.send :include, EnjuGoogleBookSearch
ActionView::Base.send :include, EnjuGoogleBookSearchHelper
