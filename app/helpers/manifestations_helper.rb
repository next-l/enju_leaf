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
        nextl.title_alternative,
        RDF::Literal.new(manifestation.title_alternative)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.title_transcription,
        RDF::Literal.new(manifestation.title_transcription)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.manifestation_identifier,
        RDF::Literal.new(manifestation.manifestation_identifier)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.pub_date,
        RDF::Literal.new(manifestation.pub_date)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.publication_place,
        RDF::Literal.new(manifestation.publication_place)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.manifestation_created_at,
        RDF::Literal.new(manifestation.created_at)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.manifestation_updated_at,
        RDF::Literal.new(manifestation.updated_at)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.carrier_type,
        RDF::Literal.new(manifestation.carrier_type.name)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.content_type,
        RDF::Literal.new(manifestation.manifestation_content_type.name)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.frequency,
        RDF::Literal.new(manifestation.frequency.name)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.language,
        RDF::Literal.new(manifestation.language.name)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.volume_number,
        RDF::Literal.new(manifestation.volume_number)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.volume_number_string,
        RDF::Literal.new(manifestation.volume_number_string)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.edition,
        RDF::Literal.new(manifestation.edition)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.edition_string,
        RDF::Literal.new(manifestation.edition_string)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.serial_number,
        RDF::Literal.new(manifestation.serial_number)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.extent,
        RDF::Literal.new(manifestation.extent)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.start_page,
        RDF::Literal.new(manifestation.start_page)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.end_page,
        RDF::Literal.new(manifestation.end_page)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.dimensions,
        RDF::Literal.new(manifestation.dimensions)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.height,
        RDF::Literal.new(manifestation.height)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.width,
        RDF::Literal.new(manifestation.width)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.depth,
        RDF::Literal.new(manifestation.depth)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.manifestation_price,
        RDF::Literal.new(manifestation.price)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.access_address,
        RDF::Literal.new(manifestation.access_address)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.manifestation_required_role,
        RDF::Literal.new(manifestation.required_role.name)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.abstract,
        RDF::Literal.new(manifestation.abstract)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.description,
        RDF::Literal.new(manifestation.description)
      )

      graph << RDF::Statement.new(
        subject,
        nextl.note,
        RDF::Literal.new(manifestation.note)
      )

      manifestation.isbn_records.each do |i|
        graph << RDF::Statement.new(
          subject,
          nextl.isbn,
          RDF::Literal.new(i.body)
        )
      end

      manifestation.identifier_contents(:issn).each do |i|
        graph << RDF::Statement.new(
          subject,
          nextl.issn,
          RDF::Literal.new(i)
        )
      end

      manifestation.identifier_contents(:jpno).each do |i|
        graph << RDF::Statement.new(
          subject,
          nextl.jpno,
          RDF::Literal.new(i)
        )
      end

      manifestation.identifier_contents(:doi).each do |i|
        graph << RDF::Statement.new(
          subject,
          nextl.doi,
          RDF::Literal.new(i)
        )
      end

      manifestation.identifier_contents(:iss_itemno).each do |i|
        graph << RDF::Statement.new(
          subject,
          nextl.iss_itemno,
          RDF::Literal.new(i)
        )
      end

      if manifestation.lccn_record
        graph << RDF::Statement.new(
          subject,
          nextl.lccn,
          RDF::Literal.new(manifestation.lccn_record)
        )
      end

      manifestation.identifier_contents(:ncid).each do |i|
        graph << RDF::Statement.new(
          subject,
          nextl.ncid,
          RDF::Literal.new(i)
        )
      end

      manifestation.identifier_contents(:loc_identifier).each do |i|
        graph << RDF::Statement.new(
          subject,
          nextl.loc_identifier,
          RDF::Literal.new(i)
        )
      end

      manifestation.identifier_contents(:issn_l).each do |i|
        graph << RDF::Statement.new(
          subject,
          nextl.issn_l,
          RDF::Literal.new(i)
        )
      end

      manifestation.identifier_contents(:epi).each do |i|
        graph << RDF::Statement.new(
          subject,
          nextl.epi,
          RDF::Literal.new(i)
        )
      end

      manifestation.series_statements.each do |i|
        graph << RDF::Statement.new(
          subject,
          nextl.series_statement_id,
          RDF::Literal.new(i.id)
        )

        graph << RDF::Statement.new(
          subject,
          nextl.series_statement_original_title,
          RDF::Literal.new(i.original_title)
        )

        graph << RDF::Statement.new(
          subject,
          nextl.series_statement_title_subseries_transcription,
          RDF::Literal.new(i.title_subseries_transcription)
        )

        graph << RDF::Statement.new(
          subject,
          nextl.series_statement_title_transcription,
          RDF::Literal.new(i.title_transcription)
        )

        graph << RDF::Statement.new(
          subject,
          nextl.series_statement_title_subseries,
          RDF::Literal.new(i.title_subseries)
        )
      end

      manifestation.creators.each do |i|
        graph << RDF::Statement.new(
          subject,
          nextl.creators,
          RDF::Literal.new(i.full_name)
        )
      end

      manifestation.contributors.each do |i|
        graph << RDF::Statement.new(
          subject,
          nextl.contributors,
          RDF::Literal.new(i.full_name)
        )
      end

      manifestation.publishers.each do |i|
        graph << RDF::Statement.new(
          subject,
          nextl.publishers,
          RDF::Literal.new(i.full_name)
        )
      end

      manifestation.subjects.each do |i|
        graph << RDF::Statement.new(
          subject,
          nextl.subject,
          RDF::Literal.new(i.term)
        )
      end

      manifestation.classifications.each do |i|
        graph << RDF::Statement.new(
          subject,
          nextl.classification,
          RDF::Literal.new(i.category)
        )
      end

      graph.dump(:turtle)
    end
  end
end
