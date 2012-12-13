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
        unless ManifestationType.is_article?(extraparams['manifestation_type'])
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

  def select_item_shelf(input_shelf, user)
    if input_shelf.blank?
      shelf = user.library.in_process_shelf
    else
      shelf = Shelf.where(:display_name => input_shelf, :library_id => user.library.id).first rescue nil
      if shelf.nil?
        raise I18n.t('resource_import_textfile.error.book.not_exsit_shelf', :shelf => input_shelf)
      end
    end
    return shelf
  end

  def set_data(model, cell, can_blank, field_name, default, check_column = :name)
    if cell.blank?
      unless can_blank
        obj = model.where(check_column => default).first
      else
        obj = nil
      end
    else
      obj = model.where(check_column => cell).first rescue nil
      if obj.nil?
        raise I18n.t('resource_import_textfile.error.book.wrong_data',
           :field => I18n.t("resource_import_textfile.excel.book.#{field_name}"), :data => cell)
      end
    end
    return obj
  end

  def check_data_is_integer(cell, field_name)
    if cell.match(/^\d*$/)
      return cell
    elsif cell.match(/^[0-9]+\.0$/)
      return cell.to_i
    elsif cell.match(/\D/)
      raise I18n.t('resource_import_textfile.error.book.only_integer',
        :field => I18n.t("resource_import_textfile.excel.book.#{field_name}"), :data => cell)
    end
  end

  def check_data_is_numeric(cell, field_name)
    if cell.match(/^\d*$/)
      return cell
    elsif cell.match(/^[0-9]+\.0$/)
      return cell.to_i
    elsif cell.match(/^[0-9]*\.[0-9]*$/)
      return cell
    else
      raise I18n.t('resource_import_textfile.error.book.only_numeric',
        :field => I18n.t("resource_import_textfile.excel.book.#{field_name}"), :data => cell)
    end
  end

  def check_data_is_date(cell, field_name)
    time = Time.zone.parse(cell) rescue nil
    unless cell.blank?
      if time.nil?
        raise I18n.t('resource_import_textfile.error.book.only_integer',
          :field => I18n.t("resource_import_textfile.excel.book.#{field_name}"), :data => cell)
      end
    end
    return time
  end

  def fix_data(cell)
    # when data is number, fix its type from float to integer
    data = cell.match(/^[0-9]+.0$/) ? cell.to_i : cell
    return data
  end

  def fix_boolean(cell)
    return true unless cell.size == 0 or cell.upcase == 'FALSE'
    false
  end
end

EnjuTrunk::ResourceAdapter::Base.add(Excelfile_Adapter)
