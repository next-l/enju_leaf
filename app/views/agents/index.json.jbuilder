json.array! @agents do |agent|
  json.agent_id agent.id
  json.label agent.full_name
  json.desc agent.full_name_transcription
end
