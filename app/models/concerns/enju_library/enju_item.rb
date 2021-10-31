module EnjuLibrary
  module EnjuItem
    extend ActiveSupport::Concern

    included do
      has_one :accept
      scope :accepted_between, lambda{|from, to| includes(:accept).where('items.created_at BETWEEN ? AND ?', Time.zone.parse(from).beginning_of_day, Time.zone.parse(to).end_of_day)}

      belongs_to :shelf, counter_cache: true, validate: true
      validates_associated :shelf

      searchable do
        string :library do
          shelf.library.name if shelf
        end
      end
    end

    def shelf_name
      shelf.name
    end

    def hold?(library)
      return true if shelf.library == library
      false
    end

    def library_url
      "#{LibraryGroup.site_config.url}libraries/#{shelf.library.name}"
    end
  end
end
