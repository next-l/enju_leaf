# -*- encoding: utf-8 -*-
class Excelfile_Adapter < EnjuTrunk::ResourceAdapter::Base

  def self.display_name
    "エクセルファイル(xlsx)"
  end

  def logger
    Rails.logger
  end

  def import(id, filename, user_id)
    logger.info "start import #{Excelfile_Adapter.display_name} #{Time.now}"
    logger.info "id=#{id} filename=#{filename}"
    puts filename

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
    end

    logger.info "end import #{Excelfile_Adapter.display_name} #{Time.now}"
  end

end

EnjuTrunk::ResourceAdapter::Base.add(Excelfile_Adapter)
