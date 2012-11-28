module ResourceImportTextfilesHelper
  def get_manifestation_types
    return ManifestationType.all
  end
end
