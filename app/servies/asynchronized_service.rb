class Asynchronized_Service
  def logger
    Rails.logger
  end

  def perform(method_identifier, param = nil)
    logger.info "Asynchronized_Service start. id=#{method_identifier}"
    case method_identifier
    when :ResoureceImportFile_import
      ResourceImportFile.import(param)
    else
      logger.error "unknown method_identifier id=#{method_identifier}"
    end
    logger.info "Asynchronized_Service end."
  end
end
