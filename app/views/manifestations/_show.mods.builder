xml.titleInfo{
  xml.title manifestation.original_title
}
xml.titleInfo('type' => 'alternative'){
  xml.title manifestation.title_alternative
}
manifestation.creators.readable_by(current_user).each do |creator|
  case creator.agent_type.name
  when "person"
    xml.name('type' => 'personal'){
      xml.namePart creator.full_name
      xml.namePart creator.date if creator.date
      xml.role do
        xml.roleTerm "creator", 'type' => 'text', 'authority' => 'marcrelator'
      end
    }
  when "corporate_body"
    xml.name('type' => 'corporate'){
      xml.namePart creator.full_name
      xml.role do
        xml.roleTerm "creator", 'type' => 'text', 'authority' => 'marcrelator'
      end
    }
  when "conference"
    xml.name('type' => 'conference'){
      xml.namePart creator.full_name
      xml.role do
        xml.roleTerm "creator", 'type' => 'text', 'authority' => 'marcrelator'
      end
    }
  end
end
manifestation.contributors.readable_by(current_user).each do |contributor|
  case contributor.agent_type.name
  when "person"
    xml.name('type' => 'personal'){
      xml.namePart contributor.full_name
      xml.namePart contributor.date if contributor.date
    }
  when "corporate_body"
    xml.name('type' => 'corporate'){
      xml.namePart contributor.full_name
    }
  when "conference"
    xml.name('type' => 'conference'){
      xml.namePart contributor.full_name
    }
  end
end
xml.typeOfResource manifestation.carrier_type.mods_type
xml.originInfo{
  manifestation.publishers.readable_by(current_user).each do |agent|
    xml.publisher agent.full_name
  end
  xml.dateIssued manifestation.date_of_publication
  xml.frequency manifestation.frequency.name
}
xml.language{
  xml.languageTerm manifestation.language.iso_639_2, 'authority' => 'iso639-2b', 'type' => 'code' if manifestation.language
}
xml.physicalDescription{
  xml.form manifestation.carrier_type.name, 'authority' => 'marcform'
  xml.extent manifestation.extent
}
if defined?(EnjuSubject)
  xml.subject{
    manifestation.subjects.each do |subject|
      xml.topic subject.term
    end
  }
  manifestation.classifications.each do |classification|
    xml.classification classification.category, 'authority' => classification.classification_type.name
  end
end
xml.abstract manifestation.description
xml.note manifestation.note
manifestation.isbn_records.each do |i|
  xml.identifier i.body, type: 'isbn'
end
xml.identifier manifestation.lccn_record.body, type: 'lccn' if manifestation.lccn_record
xml.recordInfo{
  xml.recordCreationDate manifestation.created_at
  xml.recordChangeDate manifestation.updated_at
  xml.recordIdentifier manifestation_url(manifestation)
}
