module ManifestationsHelper
  def resource_title(manifestation, action)
    string = LibraryGroup.site_config.display_name.localize.dup
    unless action == ('index' or 'new')
      if manifestation.try(:original_title)
        string << ' - ' + manifestation.original_title.to_s
      end
    end
    string << ' - Next-L Enju Leaf'
    string.html_safe
  end

  def back_to_manifestation_index
    if session[:params]
      session[:params][:output_pdf], session[:params][:output_tsv], session[:params][:output_excelx], session[:params][:output_request] = nil,nil,nil,nil
      params = session[:params].merge(:view => nil, :controller => :manifestations)
      link_to t('page.back_to_search_results'), url_for(params)
    else
      link_to t('page.back'), :back
    end
  #rescue
  #  link_to t('page.listing', :model => t('activerecord.models.manifestation')), manifestations_path
  end

  def call_number_label(item)
    if item.call_number?
      unless item.shelf.web_shelf?
        # TODO 請求記号の区切り文字
        numbers = item.call_number.split(item.shelf.library.call_number_delimiter)
        call_numbers = []
        numbers.each do |number|
          call_numbers << h(number.to_s)
        end
        render :partial => 'manifestations/call_number', :locals => {:item => item, :call_numbers => call_numbers}
      end
    end
  end

  def language_list(languages)
    list = []
    languages.each do |language|
      list << language.display_name.localize if language.name != 'unknown'
    end
    list.join("; ")
  end

  def paginate_id_link(manifestation)
    links = []
    if session[:manifestation_ids].is_a?(Array)
      current_seq = session[:manifestation_ids].index(manifestation.id)
      if current_seq
        unless manifestation.id == session[:manifestation_ids].last
          links << link_to(t('page.next'), manifestation_path(session[:manifestation_ids][current_seq + 1]))
        else
          links << t('page.next').to_s
        end
        unless manifestation.id == session[:manifestation_ids].first
          links << link_to(t('page.previous'), manifestation_path(session[:manifestation_ids][current_seq - 1]))
        else
          links << t('page.previous').to_s
        end
      end
    end
    links.join(" ").html_safe
  end

  def embed_content(manifestation)
    case
    when manifestation.youtube_id
      render :partial => 'manifestations/youtube', :locals => {:manifestation => manifestation}
    when manifestation.nicovideo_id
      render :partial => 'manifestations/nicovideo', :locals => {:manifestation => manifestation}
    when manifestation.flickr.present?
      render :partial => 'manifestations/flickr', :locals => {:manifestation => manifestation}
    when manifestation.ipaper_id
      render :partial => 'manifestations/scribd', :locals => {:manifestation => manifestation}
    end
  end

  def manifestation_page(manifestation)
    page = ""
    if manifestation.start_page and manifestation.start_page.present? and manifestation.end_page and manifestation.end_page.present?
      if manifestation.start_page == manifestation.end_page
        page = "(#{manifestation.start_page})"
      else
        page = "(#{manifestation.start_page} - #{manifestation.end_page})"
      end
    elsif (manifestation.start_page and manifestation.start_page.present?) or (manifestation.end_page and manifestation.end_page.present?)
      page = "(#{manifestation.try(:start_page)}#{manifestation.try(:end_page)})"
    end 
    page
  end

  def language_facet(language, current_languages, facet)
    string = ''
    languages = current_languages.dup
    current = true if languages.include?(language.name)
    string << "<strong>" if current
    string << link_to("#{language.display_name.localize} (" + facet.count.to_s + ")", url_for(params.merge(:page => nil, :language => language.name, :carrier_type => nil, :view => nil)))
    string << "</strong>" if current
    string.html_safe
  end

  def library_facet(library, current_libraries, facet)
    string = ''
    current = true if current_libraries.include?(library.name)
    string << "<strong>" if current
    string << link_to("#{library.display_name.localize} (" + facet.count.to_s + ")", url_for(params.merge(:page => nil, :library => (current_libraries << library.name).uniq.join(' '), :view => nil)))
    string << "</strong>" if current
    string.html_safe
  end

  def carrier_type_facet(facet)
    string = ''
    carrier_type = CarrierType.where(:name => facet.value).select([:name, :display_name]).first
    if carrier_type
      string << form_icon(carrier_type)
      current = true if params[:carrier_type] == carrier_type.name
      string << '<strong>' if current
      string << link_to("#{carrier_type.display_name.localize} (" + facet.count.to_s + ")", url_for(params.merge(:carrier_type => carrier_type.name, :page => nil, :view => nil)))
      string << '</strong>' if current
      string.html_safe
    end
  end

  def manifestation_type_facet(manifestation_type, current_manifestation_type, facet)
    string = ''
    current = true if current_manifestation_type.include?(manifestation_type.name)
    string << "<strong>" if current
    string << link_to("#{manifestation_type.display_name.localize} (" + facet.count.to_s + ")", url_for(params.merge(:manifestation_type => manifestation_type.name, :page => nil, :view => nil)))
    string << "</strong>" if current
    string.html_safe
  end

  def circulation_status_facet(type, facet)
    string = ''
    current = false
    case type
    when 'in_process'
      current = true if params[:circulation_status_in_process]
      string << "<strong>" if current
      c = CirculationStatus.find_by_name('In Process')
      string << link_to("#{c.display_name.localize} (" + facet.count.to_s + ")", url_for(params.merge(:circulation_status_in_process => true, :circulation_statua_in_factory => nil, :page => nil, :view => nil)))
    when 'in_factory'
      current = true if params[:circulation_status_in_factory]
      string << "<strong>" if current
      c = CirculationStatus.find_by_name('In Factory')
      string << link_to("#{c.display_name.localize} (" + facet.count.to_s + ")", url_for(params.merge(:circulation_status_in_factory => true, :circulation_status_in_process => nil, :page => nil, :view => nil)))
    end
    string << "</strong>" if current
    string.html_safe
  end

  def per_pages
    pages = []
    per_pages = SystemConfiguration.get("manifestations.per_page").split(',')  
    per_pages.each do |p|
      p = p.strip
      pages << p.to_i if p =~ /^[0-9]+$/
    end 
    return pages
  end

  def not_rent_book?(manifestation)
    return false if manifestation.periodical_master?
    return false if manifestation.article?
    return true if manifestation.items.empty?
    manifestation.items.each do  |i|
      return false if CirculationStatus.available_for_retain.all.map(&:id).include?(i.circulation_status.id) and i.item_identifier
    end
    true
  end

  def hide_item?(show_all = false, item)
    if @removed
      return true unless item.circulation_status.name == "Removed"
    else 
      return false if user_signed_in? and current_user.has_role?('Librarian') and show_all
      return true  if item.non_searchable
      return true  if item.try(:retention_period).try(:non_searchable)
      unless item.manifestation.article?
        return true  if item.try(:circulation_status).try(:unsearchable)
        if SystemConfiguration.get('manifestation.manage_item_rank')
          return true if item.rank == 2
        end
      end
    end
    false
  end

  if defined?(EnjuBookmark)
    def link_to_bookmark(manifestation)
      if manifestation.bookmarked?(current_user)
        link_to t('bookmark.remove_from_my_bookmark'), bookmark_path(Bookmark.where(:user_id => current_user.id, :manifestation_id => manifestation.id).first), :confirm => t('page.are_you_sure'), :method => :delete
      else
        link_to t('bookmark.add_to_my_bookmark'), new_bookmark_path(:bookmark => {:url => manifestation_url(manifestation)})
      end
    end
  end

  def binding_items(manifestation, binder_id, mode)
    if mode
      manifestation.items
    else  
      manifestation.items.where(:bookbinder_id => binder_id)
    end
  end

  def missing_issue_statuses
    list = [[I18n.t('missing_issue.no_request'), 1],
            [I18n.t('missing_issue.requested'), 2],
            [I18n.t('missing_issue.received'), 3]]
  end

  def missing_status_facet(status, current_status, facet)
    string = ''
    current = missing_status(current_status)
    string << "<strong>" if current
    string << link_to("#{missing_status(status)}(" + facet.count.to_s + ")", url_for(params.merge(:page => nil, :missing_issue => status, :carrier_type => nil, :view => nil)))
    string << "</strong>" if current
    string.html_safe
  end

  def missing_status(num)
    case num
    when 1
      I18n.t('missing_issue.no_request')
    when 2
      I18n.t('missing_issue.requested')
    when 3
      I18n.t('missing_issue.received')
    else
      nil
    end
  end
  
  def page_format(start_page, end_page)
    if start_page == end_page
      start_page
    elsif !start_page.blank? && !end_page.blank?
      "#{start_page} - #{end_page}"
    elsif start_page.blank?
      end_page
    elsif end_page.blank?
      start_page
    end
  end

  def set_serial_number(m)
    if m.serial_number_string.present? 
      m.serial_number_string = m.serial_number_string.match(/\D/) ? nil : m.serial_number_string.to_i + 1
      unless m.issue_number_string.blank?
        m.issue_number_string = m.issue_number_string.match(/\D/) ? nil : m.issue_number_string.to_i + 1
      end
    elsif m.issue_number_string.present?
      m.issue_number_string = m.issue_number_string.match(/\D/) ? nil : m.issue_number_string.to_i + 1
    elsif m.volume_number_string.present?
      m.volume_number_string = m.volume_number_string.match(/\D/) ? nil : m.volume_number_string.to_i + 1
    end
    return m
  end

  def reset_facet_params(params)
    params.merge(
            :reservable => nil,
            :carrier_type => nil,
            :library => nil,
            :in_process => nil,
            :language => nil,
            :manifestation_type => nil,
            :missing_issue => nil,
            :circulation_status_in_process => nil,
            :circulation_status_in_factory => nil,
            :page => nil,
            :view => nil
          )
    return params
  end
end
