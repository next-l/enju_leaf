def update_identifier_type
  identifier_types = YAML.safe_load(open("db/fixtures/enju_biblio/identifier_types.yml").read)
  names = identifier_types.map { |line| line[1]["name"] }
  existing_identifier_types = IdentifierType.where(name: names).index_by(&:name)
  identifier_types.each do |line|
    l = line[1].select! { |k, v| %w(name display_name note).include?(k) }
    identifier_type = existing_identifier_types[l["name"]]
    if identifier_type
      identifier_type.update!(l)
    else
      IdentifierType.create!(l)
    end
  end
end
