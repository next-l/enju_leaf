# -*- encoding: utf-8 -*-
require File.join(File.expand_path(File.dirname(__FILE__)), 'excelfile_import_book')
require File.join(File.expand_path(File.dirname(__FILE__)), 'excelfile_import_article')
class Excelfile_Adapter < EnjuTrunk::ResourceAdapter::Base
  include EnjuTrunk::ExcelfileImportBook
  include EnjuTrunk::ExcelfileImportArticle

  def self.display_name
    "エクセルファイル(xlsx)"
  end

  def self.template_filename_select_manifestation_type
    "excelfile_select_manifestation_type.html.erb"
  end

  def import(id, filename, user_id, extraparams = {})
    logger.info "#{Time.now} start import #{self.class.display_name}"
    logger.info "id=#{id} filename=#{filename}"

    Benchmark.bm do |x|
      x.report { 
        extraparams = eval(extraparams)
        manifestation_type = ManifestationType.find(extraparams['manifestation_type'])
        if manifestation_type.is_article?
          import_article(filename, id, extraparams)
        else
          import_book(filename, id, extraparams)
        end
      }
    end
    logger.info "#{Time.now} end import #{self.class.display_name}"
  end

  def fix_data(cell)
    return nil unless cell
    # when data is number, fix its type from float to integer
    data = cell.match(/^[0-9]+.0$/) ? cell.to_i : cell
    return data
  end

  def fix_boolean(cell)
    return true unless cell.blank? or cell.upcase == 'FALSE'
    false
  end
end

EnjuTrunk::ResourceAdapter::Base.add(Excelfile_Adapter)
