def update_content_type
  content_types = YAML.safe_load(open('db/fixtures/enju_biblio/content_types.yml').read)
  content_types.each do |line|
    l = line[1].select!{|k, v| %w(name display_name note).include?(k)}

    case l["name"]
    when "text"
    when "performed_music"
      content_type = ContentType.where(name: 'audio').first
      content_type.update!(l) if content_type
    when "two_dimensional_moving_image"
      content_type = ContentType.where(name: 'video').first
      content_type.update!(l) if content_type
    end

    content_type = ContentType.where(name: l["name"]).first
    ContentType.create!(l) unless content_type
  end
end
