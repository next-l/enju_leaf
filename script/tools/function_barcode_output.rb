require 'barby'
require 'barby/barcode/code_128'
require 'barby/barcode/code_128'
require 'barby/outputter/ascii_outputter'
require 'barby/outputter/rmagick_outputter'
require 'barby/outputter/png_outputter'

=begin
barcode = Barby::Code128A.new("ABC123")
#puts barcode.to_ascii
File.open("barby_test1.jpg", "wb") do |f|
  f << barcode.to_jpg
end

data = ("ABC123\306def\3074567").force_encoding("BINARY")
barcode = Barby::Code128A.new(data)
#puts barcode.to_ascii
File.open("barby_test2.jpg", "wb") do |f|
  f << barcode.to_jpg
end
=end

data = ("DUMMY\x12").force_encoding("BINARY")
barcode = Barby::Code128A.new(data)
#puts barcode.to_ascii
File.open("barby_test_f2.jpg", "wb") do |f|
  f << barcode.to_jpg
end

data = ("DUMMY\x13").force_encoding("BINARY")
barcode = Barby::Code128A.new(data)
#puts barcode.to_ascii
File.open("barby_test_f3.jpg", "wb") do |f|
  f << barcode.to_jpg
end

data = ("DUMMY\x14").force_encoding("BINARY")
barcode = Barby::Code128A.new(data)
#puts barcode.to_ascii
File.open("barby_test_f4.jpg", "wb") do |f|
  f << barcode.to_jpg
end

data = ("DUMMY\x16").force_encoding("BINARY")
barcode = Barby::Code128A.new(data)
#puts barcode.to_ascii
File.open("barby_test_f6.jpg", "wb") do |f|
  f << barcode.to_jpg
end


