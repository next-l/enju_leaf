module MessagesHelper
  def filtered_params
    params.permit([:view, :format, :page, :mode, :sort_by, :per_page])
  end
end
