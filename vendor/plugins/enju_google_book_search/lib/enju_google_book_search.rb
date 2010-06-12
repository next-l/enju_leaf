module EnjuGoogleBookSearch
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def enju_google_book_search
      include EnjuAmazon::InstanceMethods
    end
  end

  module InstanceMethods
  end
end
