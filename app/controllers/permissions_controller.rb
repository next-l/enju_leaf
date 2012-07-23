class PermissionsController < InheritedResources::Base
  load_and_authorize_resource
end
