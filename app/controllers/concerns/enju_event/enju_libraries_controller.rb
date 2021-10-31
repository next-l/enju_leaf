module EnjuEvent
  module EnjuLibrariesController
    extend ActiveSupport::Concern

    def show
      search = Sunspot.new_search(Event)
      library_id = @library.id
      search.build do
        with(:library_id).equal_to library_id
        order_by(:start_at, :desc)
      end
      page = params[:event_page] || 1
      search.query.paginate(page.to_i, Event.default_per_page)
      @events = search.execute!.results
    end
  end
end
