module EnjuQuestion
  module EnjuManifestation
    extend ActiveSupport::Concern

    def questions(options = {})
      id = self.id
      options = {page: 1, per_page: Question.default_per_page}.merge(options)
      page = options[:page]
      per_page = options[:per_page]
      user = options[:user]
      Question.search do
        with(:manifestation_id).equal_to id
        any_of do
          unless user.try(:has_role?, 'Librarian')
            with(:shared).equal_to true
          #  with(:username).equal_to user.try(:username)
          end
        end
        paginate page: page, per_page: per_page
      end.results
    end
  end
end
