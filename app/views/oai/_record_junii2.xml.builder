xml_builder.junii2 :version => '3.1',
  "xsi:schemaLocation" => "http://irdb.nii.ac.jp/oai http://irdb.nii.ac.jp/oai/junii2-3-1.xsd",
  "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
  "xmlns" => "http://irdb.nii.ac.jp/oai",
  "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
  xml_builder.title manifestation.original_title
  xml_builder.alternative manifestation.title_alternative if manifestation.title_alternative.present?
  manifestation.creators.readable_by(current_user).each do |patron|
    xml_builder.creator patron.full_name
  end
  if manifestation.try(:subjects)
    manifestation.subjects.each do |subject|
      unless subject.subject_type.name =~ /BSH|NDLSH|MeSH|LCSH/io
        xml_builder.subject subject.term
      end
    end
  end
  if manifestation.try(:classifications)
    %w[NDC NDLC].each do |c|
      manifestation.classifications.each do |classification|
        if classification.classification_type.name =~ /#{c}/i
          xml_builder.tag! c, classification.category
        end
      end
    end
  end
  if manifestation.try(:subjects)
    %w[BSH NDLSH MeSH].each do |s|
      manifestation.subjects.each do |subject|
        if subject.subject_type.name =~ /#{s}/i
          xml_builder.tag! subject, subject.term
        end
      end
    end
  end
  if manifestation.try(:classifications)
    %w[DDC LCC UDC].each do |c|
      manifestation.classifications.each do |classification|
        if classification.classification_type.name =~ /#{c}/i
          xml_builder.tag! c, classification.category
        end
      end
    end
  end
  if manifestation.try(:subjects)
    manifestation.subjects.each do |s|
      if s.subject_type.name =~ /LCSH/i
        xml_builder.tag! subject, subject.term
      end
    end
  end
  if manifestation.description?
    xml_builder.description manifestation.description
  end
  manifestation.publishers.readable_by(current_user).each do |patron|
    xml_builder.publisher patron.full_name
  end
  manifestation.contributors.readable_by(current_user).each do |patron|
    xml_builder.contributor patron.full_name
  end
  xml_builder.date manifestation.created_at.to_date.iso8601
  xml_builder.type manifestation.manifestation_content_type&.name
  if manifestation.try(:nii_type)
    xml_builder.NIItype manifestation.nii_type.name
  else
    xml_builder.NIItype 'Others'
  end
  if manifestation.attachment.attached?
    xml_builder.format manifestation.attachment.content_type
  end
  if manifestation.manifestation_identifier?
    xml_builder.identifier manifestation.manifestation_identifier
  end
  manifestation.identifiers.each do |identifier|
    unless identifier.identifier_type.name =~ /isbn|issn|ncid|doi|naid|pmid|ichushi/io
      xml_builder.identifier identifier.body
    end
  end
  xml_builder.URI manifestation_url(manifestation)
  if manifestation.attachment.present?
    xml_builder.fulltextURL manifestation_url(id: manifestation.id, format: :download)
  end
  %w[isbn issn NCID].each do |identifier|
    manifestation.identifier_contents(identifier.downcase).each do |val|
      xml_builder.tag! identifier, val
    end
  end
  if manifestation.root_series_statement
    xml_builder.jtitle manifestation.root_series_statement.original_title
  end
  xml_builder.volume manifestation.volume_number_string
  xml_builder.issue manifestation.issue_number_string
  xml_builder.spage manifestation.start_page
  xml_builder.epage manifestation.end_page
  if manifestation.pub_date?
    xml_builder.dateofissued manifestation.pub_date
  end
  # TODO: junii2: source
  if manifestation.language.blank? || manifestation.language.name == 'unknown'
    xml_builder.language "und"
  else
    xml_builder.language manifestation.language.iso_639_2
  end
  %w[pmid doi NAID ichushi].each do |identifier|
    manifestation.identifier_contents(identifier.downcase).each do |val|
      xml_builder.tag! identifier, val
    end
  end
  # TODO: junii2: isVersionOf, hasVersion, isReplaceBy, replaces, isRequiredBy, requires, isPartOf, hasPart, isReferencedBy, references, isFormatOf, hasFormat
  # TODO: junii2: coverage, spatial, NIIspatial, temporal, NIItemporal
  # TODO: junii2: rights
  # TODO: junii2: textversion
  # TODO: junii2: grantid, dateofgranted, degreename, grantor
end
