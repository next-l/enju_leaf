module ManifestationsHelper
  include EnjuAmazonHelper
  def back_to_manifestation_index
    if session[:params]
      params = session[:params].merge(:view => nil, :controller => 'manifestations')
      link_to t('page.back_to_search_results'), url_for(params)
    else
      link_to t('page.back'), :back
    end
  #rescue
  #  link_to t('page.listing', :model => t('activerecord.models.manifestation')), manifestations_path
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
        render :partial => 'manifestations/call_number', :locals => {:item => item}
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
    links.join(" ")
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

  def language_facet(language, current_languages, facet)
    string = ''
    languages = current_languages.dup
    current = true if languages.include?(language.name)
    string << "<strong>" if current
    string << link_to("#{language.display_name.localize} (" + facet.count.to_s + ")", url_for(params.merge(:page => nil, :language => (current_languages << language.name).uniq.join(' '), :carrier_type => nil, :view => nil)))
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
    carrier_type = CarrierType.first(:conditions => {:name => facet.value})
    if carrier_type
      string << form_icon(carrier_type)
      current = true if params[:carrier_type] == carrier_type.name
      string << '<strong>' if current
      string << link_to("#{carrier_type.display_name.localize} (" + facet.count.to_s + ")", url_for(params.merge(:carrier_type => carrier_type.name, :page => nil, :view => nil)))
      string << '</strong>' if current
      string.html_safe
    end
  end
end
