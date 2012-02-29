class BarcodeList < ActiveRecord::Base
  default_scope :order => 'barcode_prefix'
 
  def create_pdf_sheet(start_number,print_sheet)
      dir_base = "#{Rails.root}/private/system/barcode_list/#{self.id}/original/"
      FileUtils.mkdir_p(dir_base) unless FileTest.exist?(dir_base)

      filename = "barcode.pdf"
      File.delete(dir_base+filename) if File.exist?(dir_base+filename)
      type = "Code128B"
      prefix = ""
      digit_number = 8
      type = self.barcode_type unless self.barcode_type.blank?
      prefix = self.barcode_prefix unless self.barcode_prefix.blank?
      digit_number = self.printed_number unless self.printed_number.blank?
      @code_words = []
      num_barcode = (print_sheet.to_i) * self.sheet_type
      num_barcode.times do |i|
        digit = start_number.to_i + i 
        @code_words << prefix + sprintf('%0'+digit_number.to_s+'d',digit.to_s)
      end
      sheet = BarcodeSheet.new
      sheet.path = dir_base
      sheet.code_type = type
      sheet.create_jpgs(@code_words)
      sheet.create_pdf(filename)
      return dir_base + filename
    rescue => exc
      logger.error("barcode pdf sheet create failed: " + dir_base + filename)
      logger.info(exc)
      return
  end
end
