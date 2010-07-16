module ManifestationsHelper
  include EnjuAmazonHelper
  def back_to_resource_index
    if session[:params]
      params = session[:params].merge(:view => nil, :controller => 'resources')
      link_to t('page.back_to_search_results'), url_for(params)
    else
      link_to t('page.back'), :back
    end
  #rescue
  #  link_to t('page.listing', :model => t('activerecord.models.resource')), resources_path
  end

  def call_number_label(item)
    unless item.call_number.blank?
      unless item.shelf.web_shelf?
        # TODO 請求記号の区切り文字
        numbers = item.call_number.split(item.shelf.library.call_number_delimiter)
        @call_numbers = []
        numbers.each do |number|
          @call_numbers << h(number.to_s)
        end
        render :partial => 'call_number', :locals => {:item => item}
      end
    end
  end

  def language_list(languages)
    list = []
    languages.each do |language|
      list << h(language.display_name.localize) if language.name != 'unknown'
    end
    list.join("; ")
  end

  def paginate_id_link(resource)
    links = []
    if session[:resource_ids].is_a?(Array)
      current_seq = session[:resource_ids].index(resource.id)
      if current_seq
        unless resource.id == session[:resource_ids].last
          links << link_to(t('page.next'), resource_path(session[:resource_ids][current_seq + 1]))
        else
          links << t('page.next').to_s
        end
        unless resource.id == session[:resource_ids].first
          links << link_to(t('page.previous'), resource_path(session[:resource_ids][current_seq - 1]))
        else
          links << t('page.previous').to_s
        end
      end
    end
    links.join(" ")
  end

  def embed_content(resource)
    case
    when resource.youtube_id
      render :partial => 'youtube', :locals => {:resource => resource}
    when resource.nicovideo_id
      render :partial => 'nicovideo', :locals => {:resource => resource}
    when resource.flickr.present?
      render :partial => 'flickr', :locals => {:resource => resource}
    when resource.ipaper_id
      render :partial => 'scribd', :locals => {:resource => resource}
    end
  end

  def language_facet(language, current_languages, facet)
    string = ''
    languages = current_languages.dup
    if languages.include?(language.name)
      string << "<strong>"
    end
    string << link_to("#{language.display_name.localize} (" + facet.count.to_s + ")", url_for(params.merge(:page => nil, :language => (current_languages << language.name).uniq.join(' '), :carrier_type => nil, :view => nil)))
    if languages.include?(language.name)
      string << "</strong>"
    end
    string.html_safe
  end

  def library_facet(library, current_libraries, facet)
    string = ''
    if current_libraries.include?(library.name)
      string << "<strong>"
    end
    string << link_to("#{library.display_name.localize} (" + facet.count.to_s + ")", url_for(params.merge(:page => nil, :library => (current_libraries << library.name).uniq.join(' '), :view => nil)))
    if current_libraries.include?(library.name)
      string << "</strong>"
    end
    string.html_safe
  end

  def carrier_type_facet(facet)
    string = ''
    carrier_type = CarrierType.first(:conditions => {:name => facet.value})
    if carrier_type
      string << form_icon(carrier_type)
      if params[:carrier_type] == carrier_type.name
        string << '<strong>'
      end
      string << link_to("#{carrier_type.display_name.localize} (" + facet.count.to_s + ")", url_for(params.merge(:carrier_type => carrier_type.name, :page => nil, :view => nil)))
      if params[:carrier_type] == carrier_type.name
        string << '</strong>'
      end
      string.html_safe
    end
  end
end
