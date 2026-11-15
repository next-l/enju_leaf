def update_agent_type
  agent_types = YAML.safe_load(open("db/fixtures/enju_biblio/agent_types.yml").read)
  person_agent_type = AgentType.where(name: "Person").first
  corporate_body_agent_type = AgentType.where(name: "CorporateBody").first
  agent_types.each do |line|
    l = line[1].select! { |k, v| %w(name display_name note).include?(k) }

    case l["name"]
    when "person"
      person_agent_type.update!(l) if person_agent_type
    when "corporate_body"
      corporate_body_agent_type.update!(l) if corporate_body_agent_type
    end
  end
end
