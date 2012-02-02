# template
class Template_Adapter

  def self.display_name
    "Template Adapter (DisplayName)"
  end
  
  def self.import(filename)
    logger.info "start import #{self.name} "
    logger.info "filename=#{filename}"

  end
end

EnjuTrunk::ResourceAdapter::Base.add(Template_Adapter)
