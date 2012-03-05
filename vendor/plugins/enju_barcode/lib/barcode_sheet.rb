class BarcodeSheet
  attr_accessor :path, :code_type

  def initialization
    @path = ""
    @code_type = "Code128B"
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

  def encode(code_word)
    case @code_type
    when "Code128A"
      barcode = Barby::Code128A.new(code_word)
    when "Code128B"
      barcode = Barby::Code128B.new(code_word)
    when "Code128C"
      barcode = Barby::Code128C.new(code_word)      
    end
    return barcode.to_jpg(:height =>30, :margin => 0)
  end
end
