require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/ascii_outputter'
require 'barby/outputter/rmagick_outputter'
require 'barby/outputter/png_outputter'

def generate_barcode(s, file_prefix)
  data = s.force_encoding("BINARY")
  barcode = Barby::Code128A.new(data)
  File.open("barby_function_#{file_prefix}.jpg", "wb") do |f|
    f << barcode.to_jpg
  end
end

generate_barcode("D\x08\x12", "f2")
generate_barcode("D\x08\x13", "f3")
generate_barcode("D\x08\x14", "f4")
generate_barcode("D\x08\x16", "f6")


