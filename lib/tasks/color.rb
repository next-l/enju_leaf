def update_color
  colors = YAML.load(open('db/fixtures/enju_library/colors.yml').read)
  library_group = LibraryGroup.site_config
  colors.each do |line|
    l = line[1].select!{|k, v| %w(property code).include?(k)}
    color = Color.where(property: l["property"]).first
    unless color
      color = Color.create!(l)
      library_group.colors << color
    end
  end
end
