# template
class Template_Adapter < EnjuTrunk::ResourceAdapter::Base

  def self.display_name
    "Template Adapter (DisplayName)"
  end

  def import(filename)
    logger.info "start import #{Template_Adapter.display_name} "
    logger.info "filename=#{filename}"
    puts filename

  end

  private
  def open_import_file
    tempfile = Tempfile.new('patron_import_file')
    uploaded_file_path = self.resource_import.path

    open(uploaded_file_path){|f|
      f.each{|line|
        tempfile.puts(NKF.nkf('-w -Lu', line))
      }
    }
    tempfile.close
    tempfile.close(true)
    file.close
    rows
  end

end

EnjuTrunk::ResourceAdapter::Base.add(Template_Adapter)
