class BarcodeSheet
  require "prawn/measurement_extensions"
  attr_accessor :path, :code_type

  def initialization
    @path = self.path
    @code_type = self.code_type
  end

  def create_jpgs(code_word)
    img_dir = @path + "jpg/"
    unless File::directory?(img_dir)
      Dir::mkdir(img_dir)
    end
    img_path = img_dir + code_word + "_" + @code_type + ".jpg"
    begin
      img = encode(code_word)
    rescue => exc
      Rails.logger.info(exc)
    else
      File.open(img_path, "w+b") { |f|
        f << img
      }
    end
    return img_path
  end

  def create_pdf(barcode_list, filename, code_words)
    Rails.logger.error "create_pdf"
    coord = Struct.new("Coord", :x, :y)
    sheet = barcode_list.sheet
    # cell size (a label)
    cell = coord.new(to_pt(sheet.cell_w), to_pt(sheet.cell_h))
    cell_padding = coord.new(10,5)
    space = coord.new(to_pt(sheet.space_w), to_pt(sheet.space_h))
    
    # cell number for a sheet
    table_margin = coord.new(to_pt(sheet.margin_w-1), to_pt(sheet.margin_h))
    # barcode size
    b_width = to_pt(25)
    b_height = to_pt(12)  
  
    page = 1

    Prawn::Document.generate(@path+filename,
      :page_layout => :portrait,
      :page_size => "A4",
      :left_margin => table_margin.x,
      :top_margin => table_margin.y) do |pdf|
      pdf.font("#{Rails.root}/vendor/fonts/ipag.ttf")

      contents = []
      table_cells = []
      code_words.each_with_index do |code_word, index|
        barcode = create_jpgs(code_word)
        if File.exist?(barcode)
          contents[index] = pdf.make_table([[{:image => barcode, :fit => [b_width, b_height], :vposition => 5, :position => :center, :height => 30}], 
                                            [code_word], [barcode_list.label_note]],
                                            :width => cell.x+space.x, :cell_style => {:width => cell.x+space.x, :border_width => [0,0,0,0]})
        else
          contents[index] = pdf.make_table([["NO BARCODE"], [code_word], [barcode_list.label_note]],
                                           :width => cell.x+space.x, :cell_style => {:width => cell.x+space.x, :border_width => [0,0,0,0]})
        end
      end
      contents.each_slice(4){|row| table_cells << row}

      pdf.table(table_cells) do |t|
        t.cells.borders = [:top, :bottom, :left, :right]
        t.cells.border_width = [0,space.x,space.y,0]
        t.cells.border_colors = 'ffffff'
        t.cells.height = cell.y+space.y
        t.cells.width = cell.x+space.x

        t.cells.each do |cell|
          cell.padding = [space.y/2,space.x/2,8,0]
          cell.subtable.row(1..2).align = :center
          cell.subtable.row(1..2).overflow = :shrink_to_fit
          cell.subtable.row(1..2).padding = 0
          cell.subtable.row(1).size = 8 
          cell.subtable.row(1).height = 10
          cell.subtable.row(2).size = 10
          cell.subtable.row(2).height = 10
        end
      end
    end
    return @path+filename
  end

  def encode(code_word)
    case @code_type
    when "Code128A"
      barcode = Barby::Code128A.new(code_word)
    when "Code128B"
      barcode = Barby::Code128B.new(code_word)
    when "Code128C"
      barcode = Barby::Code128C.new(code_word)      
    when "nw-7"
      Rails.logger.error "creating nw-7"
#      doc = RGhost::Document.new :paper => ['25 mm', '12 mm']
#      barcode = doc.barcode_rationalizedcodabar code_word, :x => 0, :y => 0, :width => '25 mm', :height => '12 mm'
#      io = StringIO.new(doc.render_stream(:jng))
#      return io.respond_to?(:set_encoding) ? io.set_encoding('UTF-8') : io
    end
    return barcode.to_jpg(:height => to_pt(12), :width => to_pt(25), :margin => 0)
  end

  def to_pt(num)
    num.mm2pt(num)
  end

end
