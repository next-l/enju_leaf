    xml.title manifestation.original_title
    xml.link manifestation_url(manifestation)
    xml.description [ agents_list(manifestation.publishers, nolink: true), manifestation.pub_date, manifestation.description ].reject(&:blank?).join("; ")
