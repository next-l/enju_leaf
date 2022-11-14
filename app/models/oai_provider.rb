class OaiProvider < OAI::Provider::Base
  library_group = LibraryGroup.site_config
  repository_name library_group.display_name
  repository_url EnjuOai::OaiModel.repository_url
  record_prefix EnjuOai::OaiModel.record_prefix
  admin_email library_group.email
  source_model OAI::Provider::ActiveRecordWrapper.new(
    Manifestation.where(required_role: 1)
  )
end
