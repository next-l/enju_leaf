# -*- encoding: utf-8 -*-
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
        if extraparams["is_article"] != 'true'
          import_book(filename, id, extraparams)
        else
          import_article(filename, id, extraparams)
        end    
      }
    end
    logger.info "#{Time.now} end import #{self.class.display_name}"
  end

  def import_item(manifestation, options)
    item = Item.new(options)
    item.manifestation = manifestation
    if item.save!
      item.patrons << options[:shelf].library.patron
    end
    return item
  end

  def select_item_shelf(user)
    if user
      return user.library.in_process_shelf
    end
    unless shelf
      return Shelf.web
    end
  end
end

EnjuTrunk::ResourceAdapter::Base.add(Excelfile_Adapter)
