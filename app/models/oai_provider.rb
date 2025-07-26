class OaiProvider < OAI::Provider::Base
  library_group = LibraryGroup.site_config
  if library_group
    repository_name library_group.display_name
    admin_email library_group.email
  end
  repository_url EnjuOai::OaiModel.repository_url
  record_prefix EnjuOai::OaiModel.record_prefix
  source_model OAI::Provider::ActiveRecordWrapper.new(
    Manifestation.where(required_role: 1)
  )
end
