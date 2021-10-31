def update_agent_type
  agent_types = YAML.load(open('db/fixtures/enju_biblio/agent_types.yml').read)
  agent_types.each do |line|
    l = line[1].select!{|k, v| %w(name display_name note).include?(k)}

    case l["name"]
    when "person"
      agent_type = AgentType.where(name: 'Person').first
      agent_type.update!(l) if agent_type
    when "corporate_body"
      agent_type = AgentType.where(name: 'CorporateBody').first
      agent_type.update!(l) if agent_type
    end
  end
end
