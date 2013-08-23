class Asynchronized_Service
  def logger
    Rails.logger
  end

  def perform(method_identifier, param = nil) # param = id of object offering the method
    logger.info "Asynchronized_Service start. method: #{method_identifier} id: #{param}"
    case method_identifier
    when :ResoureceImportFile_import
      import = ResoureceImportFile.find(param)
      if import.state == 'pending'
        ResourceImportFile.delay.import(param)
        #TODO import.sm_request!
      end
    when :ResourceImportTextfile_import
      import = ResourceImportTextfile.find(param)
      if import.state == 'pending' # only pending request can be queued 
        ResourceImportTextfile.delay.import(param) 
        import.sm_request!
      end
    when :PatronImportFile_import
      import = PatronImportFile.find(param)
      if import.state == 'pending'
        PatronImportFile.import(param)
        #TODO import.sm_request!
      end
    when :EventImportFile_import
      import = EventImportFile.find(param)
      if import.state == 'pending'
        EventImportFile.import(param)
        #TODO import.sm_request!
      end
    when :InventoryCheck_exec
      InventoryManage.check(param)
      #if defined?(InventoryManage) 
      #  InventoryManage.check(param)
      #else
      #  logger.info "InventoryManage not defined."
      #end
    when :InventoryShelfBarcodeImportFile_import
      InventoryShelfBarcodeImportFile.import(param)
    when :InventoryCheckDataImportFile_import
      InventoryCheckDataImportFile.import(param)
    else
      logger.error "unknown method_identifier id=#{method_identifier}"
    end
    logger.info "Asynchronized_Service end."
  end
end
