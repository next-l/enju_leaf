class BarcodeSheet
  require "prawn/measurement_extensions"
  require "cgi"
  attr_accessor :path, :code_type

  def initialization
    @path = self.path
    @code_type = self.code_type
  end

  def create_jpgs(code_words, sup_words = nil)
    img_dir = @path + "jpg/"
    unless File::directory?(img_dir)
      Dir::mkdir(img_dir)
    end
    @img_files = []
    @code_words = code_words
    @sup_words = sup_words
    @code_words.each do |code_word|
      img_path = img_dir + code_word + "_" + @code_type + "jpg"
      @img_files << img_path
      begin
        img = encode(code_word)
      rescue => exc
        Rails.logger.info(exc)
      else
        File.open(img_path, "w+b") { |f|
          f << img
        }
      end
    end 
  end

  def create_pdf(filename)
    coord = Struct.new("Coord", :x, :y)
    init = coord.new(30, 731)
    pos = coord.new(init.x, init.y)
    inter = coord.new(170, 72)
    code_words = @code_words
    img_files = @img_files
    code_type = @code_type
    page = 1
    sup_words = @sup_words
    Prawn::Document.generate(@path+filename,
      :page_layout => :portrait,
      :page_size => "A4") do
      font("#{Rails.root}/vendor/fonts/ipag.ttf")
      code_words.each_with_index { |code_word, index|
        if File.exist?(img_files[index])
          image img_files[index], :at => [pos.x, pos.y], :scale => 0.75
          draw_text code_word, :at => [pos.x,pos.y-40], :size => 10
          if sup_words and sup_words[index].present?
            t = sup_words[index].slice(0, 20)
            draw_text t, :at => [pos.x,pos.y-50], :size => 8
          end
        else
          draw_text code_type, :at => [pos.x, pos.y]
          draw_text "encoding error", :at => [pos.x, pos.y-20]
          draw_text code_word, :at => [pos.x,pos.y-40], :size => 10
        end
        # next step
        if (index + 1) % 3 == 0
          pos.x = init.x
          pos.y -= inter.y
        else
          pos.x += inter.x
        end
        if (index + 1) % 30 == 0
            unless code_words[index + 1].nil?
              start_new_page
              page += 1
              draw_text "Page " + page.to_s, :at => [30, 5]
              pos.y = init.y
            end
        end
        if index == 0
          draw_text "Page " + page.to_s, :at => [30, 5]
        end
      }
    end
    return @path+filename
  end

# =========== 2012.10.17 to create barcode_list ===============
  def create_jpgs_new(code_word)
    img_dir = @path + "jpg/"
    unless File::directory?(img_dir)
      Dir::mkdir(img_dir)
    end
    # escaping code word just in case it contains control codes or sth
    img_path = img_dir + CGI.escape(code_word) + "_" + @code_type + ".jpg"
    begin
      img = encode(code_word)    
    rescue => exc
      Rails.logger.info("failed created_jpg_new: #{exc}")
    else
      File.open(img_path, "w+b") { |f|
        f << img
      }
    end
    return img_path
  end

  def create_pdf_new(barcode_list, filename, code_words)
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
        barcode = create_jpgs_new(code_word)
        if File.exist?(barcode)
          # TODO: setting the height to 30 causes short barcodes
          #       not to appear on the pdf sheet - temporarily set
          #       the height to 60 here...
          contents[index] = pdf.make_table([[{:image => barcode, :fit => [b_width, b_height], :vposition => 5, :position => :center, :height => 60}], 
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
    case @code_type.upcase
    when "CODE128A"
      # backslashes in the form fields are being escaped
      # - here's the hack to unescape the backslashes
      barcode = Barby::Code128A.new(eval "\"#{code_word}\"")
    when "CODE128B"
      barcode = Barby::Code128B.new(eval "\"#{code_word}\"")
    when "CODE128C"
      barcode = Barby::Code128C.new(eval "\"#{code_word}\"")
    when "NW-7"
      doc = RGhost::Document.new :paper => ['5cm', '2.1cm'], :rows_per_page => 1, :row_height => 0.9, :row_padding => 0.1
      #doc.barcode_rationalizedCodabar(code_word,{:x => 0, :y => 0, :width => to_pt(25), :height => to_pt(12)})
      #doc.barcode_rationalizedCodabar(code_word, {:text=>{:size=>8}, :enable=>[:text, :checkintext, :check]})
      doc.barcode_rationalizedCodabar(code_word, {:height => to_pt(12)})
      return doc.render_stream(:jpg)
    end
    return barcode.to_jpg(:height => to_pt(12), :width => to_pt(25), :margin => 0)
  end

  def to_pt(num)
    num.mm2pt(num)
  end

end
