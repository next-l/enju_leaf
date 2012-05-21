module ShelvesHelper
  def library_facet(library, current_library, facet)
    string = ''
    current = true if current_library.try(:name) == library.name
    string << "<strong>" if current
    string << link_to("#{library.display_name.localize} (" + facet.count.to_s + ")", url_for(params.merge(:page => nil, :library_id => library.name)))
    string << "</strong>" if current
    string.html_safe
  end
end
