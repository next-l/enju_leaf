class BarcodeList < ActiveRecord::Base
  default_scope :order => 'barcode_prefix'

  attr_accessor :end_number

  def create_pdf_user_number_list(start_number, end_number)
    dir_base = "#{Rails.root}/private/system/barcode_list/#{self.id}/original/"
    FileUtils.mkdir_p(dir_base) unless FileTest.exist?(dir_base)

    filename = "barcode.pdf"
    File.delete(dir_base+filename) if File.exist?(dir_base+filename)
    type = "Code128B"
    prefix = ""
    prefix = self.barcode_prefix unless self.barcode_prefix.blank?
    @code_words = []
    @sup_words = []

    user_numbers = User.order(:user_number).includes(:patron)
    if start_number && start_number.strip.present?
      user_numbers = user_numbers.where("user_number >= ?", start_number)
    end
    if end_number && end_number.strip.present?
      user_numbers = user_numbers.where("user_number <= ?", end_number)
    end

    user_numbers.each do |u|
      @code_words << prefix + u.user_number unless u.user_number.blank?
      title = u.patron.full_name || ""
      @sup_words << title
    end
    sheet = BarcodeSheet.new
    sheet.path = dir_base
    sheet.code_type = type
    sheet.create_jpgs(@code_words, @sup_words)
    sheet.create_pdf(filename)
    return dir_base + filename
  end

  def create_pdf_item_identifier_list(start_number, end_number)
    dir_base = "#{Rails.root}/private/system/barcode_list/#{self.id}/original/"
    FileUtils.mkdir_p(dir_base) unless FileTest.exist?(dir_base)

    filename = "barcode.pdf"
    File.delete(dir_base+filename) if File.exist?(dir_base+filename)
    type = "Code128B"
    prefix = ""
    prefix = self.barcode_prefix unless self.barcode_prefix.blank?
    @code_words = []
    @sup_words = []
    items = Item.order(:item_identifier).includes(:manifestation)
    if start_number && start_number.strip.present?
      items = items.where("item_identifier >= ?", start_number)
    end
    if end_number && end_number.strip.present?
      items = items.where("item_identifier <= ?", end_number)
    end

    items.each do |item|
      unless item.item_identifier.blank?
        @code_words << prefix + item.item_identifier 
        title = item.manifestation.try(:original_title) || ""
        @sup_words << title
      end
    end
    sheet = BarcodeSheet.new
    sheet.path = dir_base
    sheet.code_type = type
    sheet.create_jpgs(@code_words, @sup_words)
    sheet.create_pdf(filename)
    return dir_base + filename
  end
 
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
