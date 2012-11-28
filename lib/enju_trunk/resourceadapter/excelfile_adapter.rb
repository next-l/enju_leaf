# -*- encoding: utf-8 -*-
class Excelfile_Adapter < EnjuTrunk::ResourceAdapter::Base

  def self.display_name
    "エクセルファイル(xlsx)"
  end

  def self.template_filename_select_manifestation_type
    "excelfile_select_manifestation_type.html.erb"
  end

    oo = Excelx.new(filename)

    puts "sheet list"
    oo.sheets.each_with_index do |s, i|
      puts "sheet no=#{i} name=#{s.to_s}"
    end

    puts "first sheet cells"
    oo.default_sheet = oo.sheets.first
    2.upto(5) do |line|
      c1 = oo.cell(line,'A')
      c2 = oo.cell(line,'B')
      c3 = oo.cell(line,'C')
      c4 = oo.cell(line,'D')
      puts "c1=#{c1} c2=#{c2} c3=#{c3} c4=#{c4}"
      num = num + 1
    end

    return num;
  end

  def import(id, filename, user_id)
    logger.info "#{Time.now} start import #{self.class.display_name}"
    logger.info "id=#{id} filename=#{filename}"

    Benchmark.bm do |x|
      x.report {
        num = import_from_file(filename)
        logger.info "result: #{num}"
      }
    end

    logger.info "#{Time.now} end import #{self.class.display_name}"
  end

end

EnjuTrunk::ResourceAdapter::Base.add(Excelfile_Adapter)
