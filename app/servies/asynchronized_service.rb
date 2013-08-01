class Asynchronized_Service
  def logger
    Rails.logger
  end

  def perform(method_identifier, param = nil)
    logger.info "Asynchronized_Service start. id=#{method_identifier}"
    case method_identifier
    when :ResoureceImportFile_import
      ResourceImportFile.import(param)
    when :ResourceImportTextfile_import
      ResourceImportTextfile.import(param)
    when :PatronImportFile_import
      PatronImportFile.import(param)
    when :EventImportFile_import
      EventImportFile.import(param)
    when :InventoryCheck_exec
      InventoryManage.check(param)
      #if defined?(InventoryManage) || 1
      #  InventoryManage.check(param)
      #else
      #  logger.info "InventoryManage not defined."
      #end
    else
      logger.error "unknown method_identifier id=#{method_identifier}"
    end
    logger.info "Asynchronized_Service end."
  end
end
