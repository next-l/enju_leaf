class OaiProvider < OAI::Provider::Base
  library_group = LibraryGroup.site_config
  repository_name library_group.display_name
  repository_url URI.join(ENV['ENJU_LEAF_BASE_URL'], '/oai')
  record_prefix "oai:#{URI.parse(ENV['ENJU_LEAF_BASE_URL']).host}:manifestations"
  admin_email library_group.email
  source_model OAI::Provider::ActiveRecordWrapper.new(
    Manifestation.where(required_role: 1)
  )
end
