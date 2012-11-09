# template
class Template_Adapter < EnjuTrunk::ResourceAdapter::Base

  def self.display_name
    "Template Adapter (DisplayName)"
  end
=begin
  def self.template_filename_show
  end

  def self.template_filename_edit
  end
=end

  def import(filename)
    logger.info "#{Time.now} start import #{self.class.display_name}"
    logger.info "id=#{id} filename=#{filename}"

    #Proccess

    logger.info "#{Time.now} end import #{self.class.display_name}"
  end


end

EnjuTrunk::ResourceAdapter::Base.add(Template_Adapter)
