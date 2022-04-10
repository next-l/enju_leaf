def update_message_template
  YAML.safe_load(open('db/fixtures/enju_message/message_templates.yml').read).each do |line|
    l = line[1].select!{|k, v| %w(status locale title body).include?(k)}
    template = MessageTemplate.where(
      status: l["status"], locale: l["locale"]
    ).first
    if template
      template.update!(l)
    else
      MessageTemplate.create!(l)
    end
  end
end
