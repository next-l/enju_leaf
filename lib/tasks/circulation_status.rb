def update_circulation_status
  lines = YAML.safe_load(open("db/fixtures/enju_circulation/circulation_statuses.yml").read)
  names = lines.map { |line| line[1]["name"] }
  existing_circulation_statuses = CirculationStatus.where(name: names).index_by(&:name)
  lines.each do |line|
    l = line[1].select! { |k, v| %w(name display_name).include?(k) }
    existing_circulation_statuses[l["name"]]&.update_attributes!(l)
  end
end
