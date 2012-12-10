module ManifestationTypesHelper
  def get_manifestation_type_name(id)
    return ManifestationType.find(id).display_name.localize
  end
end
