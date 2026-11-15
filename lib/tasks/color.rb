def update_color
  colors = YAML.safe_load(open("db/fixtures/enju_library/colors.yml").read)
  library_group = LibraryGroup.site_config
  properties = colors.map { |line| line[1]["property"] }
  existing_colors = Color.where(property: properties).index_by(&:property)
  colors.each do |line|
    l = line[1].select! { |k, v| %w(property code).include?(k) }
    color = existing_colors[l["property"]]
    unless color
      color = Color.create!(l)
      library_group.colors << color
    end
  end
end
