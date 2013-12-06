module ShelvesHelper
  def i18n_open_access(open_access)
    case open_access.to_i
    when 0
      t('activerecord.attributes.shelf.open')
    when 1
      t('activerecord.attributes.shelf.closed')
    when 2
      t('activerecord.attributes.shelf.stock')
    when 9
      t('activerecord.attributes.shelf.in_process')
    end
  end

  def library_facet(library, current_libraries, facet)
    string = ''
    current = true if current_libraries.include?(library.name)
    string << "<strong>" if current
    string << link_to("#{library.display_name.localize} (" + facet.count.to_s + ")", url_for(params.merge(:page => nil, :library => (current_libraries << library.name).uniq.join(' '), :view => nil)))
    string << "</strong>" if current
    string.html_safe
  end

  def open_access_facet(open_access, current_open_access, facet)
    open_access = open_access.to_s
    string = ''
    current = true if current_open_access.include?(open_access)
    string << "<strong>" if current
    string << link_to("#{i18n_open_access(open_access)} (" + facet.count.to_s + ")", url_for(params.merge(:page => nil, :open_access => (current_open_access << open_access).uniq.join(' '), :view => nil)))
    string << "</strong>" if current
    string.html_safe
  end
end
