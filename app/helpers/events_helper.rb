module EventsHelper
  def filtered_params
    params.permit([:format, :library_id, :mode, :query, :page, :per_page])
  end
end
