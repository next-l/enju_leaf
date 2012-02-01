class ResourceImportTextfile < ActiveRecord::Base
  include ImportFile
  default_scope :order => 'id DESC'
  scope :not_imported, where(:state => 'pending', :imported_at => nil)

  def self.import(id = nil)
    if !id.nil?
      file = ResourceImportFile.find(id) rescue nil
      file.import_start unless file.nil?
    else
      ResourceImportFile.not_imported.each do |file|
        file.import_start
      end
    end
  rescue Exception => e
    logger.info "#{Time.zone.now} importing resources failed! #{e}"
  end
end
