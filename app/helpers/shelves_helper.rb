module ShelvesHelper
  def library_shelf_facet(library, current_library, facet)
    string = ''
    current = true if current_library.try(:name) == library.name
    if current
      content_tag :strong do
        link_to("#{library.display_name.localize} (" + facet.count.to_s + ")", url_for(params.merge(:page => nil, :library_id => library.name, :only_path => true)))
      end
    else
      link_to("#{library.display_name.localize} (" + facet.count.to_s + ")", url_for(params.merge(:page => nil, :library_id => library.name, :only_path => true)))
    end
  end
end
