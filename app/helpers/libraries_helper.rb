module LibrariesHelper
  def filtered_params
    params.permit([:q, :query, :view, :format, :order, :sort_by, :page, :per_page])
  end
end
