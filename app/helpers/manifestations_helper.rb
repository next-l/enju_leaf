module ManifestationsHelper
  # include EnjuCirculation::ManifestationsHelper if defined?(EnjuCirculation)

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
      params = session[:params].merge(view: nil, controller: :manifestations)
      link_to t('page.back_to_search_results'), url_for(params)
    else
      link_to t('page.back'), :back
    end
  #rescue
  #  link_to t('page.listing', model: t('activerecord.models.manifestation')), manifestations_path
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
        render partial: 'manifestations/call_number', locals: { item: item, call_numbers: call_numbers }
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

  def paginate_id_link(manifestation, manifestation_ids)
    links = []
    if manifestation_ids.is_a?(Array)
      current_seq = manifestation_ids.index(manifestation.id)
      if current_seq
        unless manifestation.id == manifestation_ids.last
          links << link_to(t('page.next'), manifestation_path(manifestation_ids[current_seq + 1]))
        else
          links << t('page.next').to_s
        end
        unless manifestation.id == manifestation_ids.first
          links << link_to(t('page.previous'), manifestation_path(manifestation_ids[current_seq - 1]))
        else
          links << t('page.previous').to_s
        end
      end
    end
    links.join(" ").html_safe
  end

  def language_facet(language, current_languages, facet)
    string = ''
    languages = current_languages.dup
    current = true if languages.include?(language.name)
    if current
      content_tag :strong do
        link_to("#{language.display_name.localize} (" + facet.count.to_s + ")", url_for(request.params.merge(page: nil, language: language.name, view: nil, only_path: true)))
      end
    else
      link_to("#{language.display_name.localize} (" + facet.count.to_s + ")", url_for(request.params.merge(page: nil, language: language.name, view: nil, only_path: true)))
    end
  end

  def library_facet(current_libraries, facet)
    library = Library.where(name: facet.value).select([:name, :display_name]).first
    return nil unless library

    string = ''
    current = true if current_libraries.include?(library.name)
    content_tag :li do
      if current
        content_tag :strong do
          link_to("#{library.display_name.localize} (" + facet.count.to_s + ")", url_for(request.params.merge(page: nil, library: (current_libraries << library.name).uniq.join(' '), view: nil, only_path: true)))
        end
      else
        link_to("#{library.display_name.localize} (" + facet.count.to_s + ")", url_for(request.params.merge(page: nil, library: (current_libraries << library.name).uniq.join(' '), view: nil, only_path: true)))
      end
    end
  end

  def carrier_type_facet(facet)
    string = ''
    carrier_type = CarrierType.where(name: facet.value).select([:id, :name, :display_name]).first
    if carrier_type
      string << form_icon(carrier_type)
      current = true if params[:carrier_type] == carrier_type.name
      if current
        content_tag :strong do
          link_to("#{carrier_type.display_name.localize} (" + facet.count.to_s + ")", url_for(request.params.merge(carrier_type: carrier_type.name, page: nil, view: nil, only_path: true)))
        end
      else
        link_to("#{carrier_type.display_name.localize} (" + facet.count.to_s + ")", url_for(request.params.merge(carrier_type: carrier_type.name, page: nil, view: nil, only_path: true)))
      end
    end
  end

  def pub_year_facet(pub_date_from, pub_date_until, facet)
    current = true if facet.value.first.to_i == pub_date_from.to_i and facet.value.last.to_i - 1 == pub_date_until.to_i
    if current
      content_tag :strong do
        link_to("#{facet.value.first.to_i} - #{facet.value.last.to_i - 1} (" + facet.count.to_s + ")", url_for(request.params.merge(pub_date_from: facet.value.first.to_i, pub_date_until: facet.value.last.to_i - 1, page: nil, view: nil, only_path: true)))
      end
    else
      link_to("#{facet.value.first.to_i} - #{facet.value.last.to_i - 1} (" + facet.count.to_s + ")", url_for(request.params.merge(pub_date_from: facet.value.first.to_i, pub_date_until: facet.value.last.to_i - 1, page: nil, view: nil, only_path: true)))
    end
  end

  def title_with_volume_number(manifestation)
    title = manifestation.original_title
    if manifestation.volume_number_string?
      title << " " + manifestation.volume_number_string
    end
    if manifestation.serial?
      if manifestation.issue_number_string?
        title << " (#{manifestation.issue_number_string})"
      end
      if manifestation.serial_number?
        title << " " + manifestation.serial_number.to_s
      end
    end
    title
  end

  def holding_item_sort_criteria(item)
    own_library = 2
    own_library = 1 if signed_in? and current_user.profile.library_id == item.shelf.library_id
    [own_library, Library.find(item.shelf.library_id).position, item.shelf.position, item.id]
  end

  def link_to_reservation(manifestation, reserve)
    if current_user
      if current_user.has_role?('Librarian')
        link_to t('manifestation.reserve_this'), new_reserve_path(manifestation_id: manifestation.id)
      else
        if manifestation.is_checked_out_by?(current_user)
          I18n.t('manifestation.currently_checked_out')
        else
          if manifestation.is_reserved_by?(current_user)
            link_to t('manifestation.cancel_reservation'), reserve, confirm: t('page.are_you_sure'), method: :delete
          else
            link_to t('manifestation.reserve_this'), new_reserve_path(manifestation_id: manifestation.id)
          end
        end
      end
    else
      unless manifestation.items.for_checkout.empty?
        link_to t('manifestation.reserve_this'), new_reserve_path(manifestation_id: manifestation.id)
      end
    end
  end

  if defined?(EnjuBookmark)
    def link_to_bookmark(manifestation)
      if manifestation.bookmarked?(current_user)
        link_to t('bookmark.remove_from_my_bookmark'), bookmark_path(Bookmark.where(user_id: current_user.id, manifestation_id: manifestation.id).first), confirm: t('page.are_you_sure'), method: :delete
      else
        link_to t('bookmark.add_to_my_bookmark'), new_bookmark_path(bookmark: {url: manifestation_url(manifestation)})
      end
    end

    def rdf_statement(manifestation)
      nextl = RDF::Vocabulary.new('https://next-l.jp/vocab/')
      subject = RDF::URI.new(manifestation_url(manifestation))
      graph = RDF::Graph.new

      graph << RDF::Statement.new(
        subject,
        nextl.original_title,
        RDF::Literal.new(manifestation.original_title)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.description,
        RDF::Literal.new(manifestation.description)
      )

      manifestation.creators.each do |i|
        graph << RDF::Statement.new(
          subject,
          nextl.creators,
          RDF::Literal.new(creator.full_name)
        )
      end

      graph.dump(:turtle)
    end
  end
end
