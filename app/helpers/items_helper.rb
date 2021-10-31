module ItemsHelper
  def circulation_status_facet(facet)
    string = ''
    circulation_status = CirculationStatus.where(name: facet.value).select([:name, :display_name]).first
    if circulation_status
      # string << form_icon(circulation_status)
      current = true if params[:circulation_status] == circulation_status.name
      if current
        content_tag :strong do
          link_to("#{circulation_status.display_name.localize} (" + facet.count.to_s + ")", url_for(filtered_params.merge(circulation_status: circulation_status.name, page: nil, view: nil, only_path: true)))
        end
      else
        link_to("#{circulation_status.display_name.localize} (" + facet.count.to_s + ")", url_for(filtered_params.merge(circulation_status: circulation_status.name, page: nil, view: nil, only_path: true)))
      end
    end
  end
end
