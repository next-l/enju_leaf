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
        manifestation_types = extraparams["manifestation_type"]
        numberings = extraparams["numbering"]
        @textfile_id = id
        @oo = Excelx.new(filename)
        errors = []
        
        extraparams["sheet"].each_with_index do |sheet, i|
          @manifestation_type = ManifestationType.find(manifestation_types[i].to_i)
          @numbering = Numbering.where(:name => numberings[i]).first rescue nil
          unless @numbering
            case 
            when @manifestation_type.is_book?
              @numbering = Numbering.where(:name => 'book').first
            when @manifestation_type.is_article?
              @numbering = Numbering.where(:name => 'article').first
            else 
              @numbering = Numbering.where(:name => 'book').first
            end
          end
          @oo.default_sheet = sheet
          logger.info "num=#{i}  sheet=#{sheet} manifestation_type=#{@manifestation_type.display_name}"

          if @manifestation_type.is_article?
            import_article(sheet, errors)
          else
            import_book(sheet, errors)
          end
        end
        if errors.size > 0
          errors.each do |error|
            import_textresult = ResourceImportTextresult.new(
              :resource_import_textfile_id => @textfile_id,
              :extraparams                 => "{'sheet'=>'#{error[:sheet]}', 'wrong_sheet' => true, 'filename' => '#{filename}' }",
              :error_msg                   => error[:msg],
              :failed                      => true
             )
            import_textresult.save!
          end
        end
      }
    end
    logger.info "#{Time.now} end import #{self.class.display_name}"
  end

  def fix_data(cell)
    return nil unless cell
    cell = cell.to_s.strip

    if cell.match(/^[0-9]+.0$/)
      return cell.to_i
    elsif cell == 'delete'
      return ''
    elsif cell.blank? or cell.nil?
      return nil
    else
      return cell.to_s
    end
  end

  def fix_boolean(cell, options = {:mode => 'create'})
    unless cell
      if options[:mode] == 'delete' or @mode == 'edit' or @mode_item == 'edit'
        return nil
      else
        return false
      end
    end
    cell = cell.to_s.strip

    if cell.nil? or cell.blank? or cell.upcase == 'FALSE' or cell == ''
      return false
    end
    return true
  end
end

EnjuTrunk::ResourceAdapter::Base.add(Excelfile_Adapter)
