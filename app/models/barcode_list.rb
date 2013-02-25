class BarcodeList < ActiveRecord::Base
  attr_accessible :barcode_name, :sheet_id, :usage_type, :barcode_type, :barcode_prefix,
                  :barcode_suffix, :label_note, :printed_number

  default_scope :order => 'barcode_prefix'
  BARCODE_TYPES = ["Code128A","Code128B","NW-7"]
  GENERATED_FROM = (I18n.t('activerecord.attributes.barcode_list.generated_from')).split(",")

  attr_accessor :start_number, :end_number
  attr_accessor :custom_barcodes

  belongs_to :sheet

  RGhost::Config::GS[:path]='/usr/local/bin/gs' 

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
      title = ""
      if u.patron
        if u.patron.full_name
          title = u.patron.full_name  
        end
      end
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
 
  def create_pdf_sheet(start_number,end_number)
      dir_base = "#{Rails.root}/private/system/barcode_list/#{self.id}/original/"
      FileUtils.mkdir_p(dir_base) unless FileTest.exist?(dir_base)
      #filename = "barcode#{Time.now.strftime('%s')}.pdf"
      filename = "barcode.pdf"
      File.delete(dir_base+filename) if File.exist?(dir_base+filename)

      barcode_sheet = self.sheet
      digit_number = 8
      digit_number = self.printed_number unless self.printed_number.blank?
      type = self.barcode_type unless self.barcode_type.blank?
      prefix = self.barcode_prefix unless self.barcode_prefix.blank?
      suffix = self.barcode_suffix unless self.barcode_suffix.blank?
      digit_number = self.printed_number unless self.printed_number.blank?

      @code_words = []
      num_barcode = end_number.to_i - start_number.to_i
      num_barcode.times do |i|
        digit = start_number.to_i + i 
        #@code_words << prefix + sprintf('%0'+digit_number.to_s+'d',digit.to_s) + suffix
        @code_words << sprintf('%0'+digit_number.to_s+'d',digit.to_s) 
      end

puts @code_words

      sheet = BarcodeSheet.new
      sheet.path = dir_base
      sheet.code_type = type
      sheet.create_pdf_new(self, filename, @code_words)
      return dir_base + filename
    rescue => exc
      logger.error("barcode pdf sheet create failed: " + dir_base + filename)
      logger.info(exc)
      logger.info($@.join("\n"))
      return
  end
 
  def create_pdf_sheet_custom(custom_barcodes)
      dir_base = "#{Rails.root}/private/system/barcode_list/#{self.id}/original/"
      FileUtils.mkdir_p(dir_base) unless FileTest.exist?(dir_base)
      #filename = "barcode#{Time.now.strftime('%s')}.pdf"
      filename = "barcode.pdf"
      File.delete(dir_base+filename) if File.exist?(dir_base+filename)

      barcode_sheet = self.sheet
      digit_number = 3
      digit_number = self.printed_number unless self.printed_number.blank?
      type = self.barcode_type unless self.barcode_type.blank?
      prefix = self.barcode_prefix unless self.barcode_prefix.blank?
      suffix = self.barcode_suffix unless self.barcode_suffix.blank?
      digit_number = self.printed_number unless self.printed_number.blank?

      # delete null elements (ie custom barcode not entered)
      custom_barcodes.delete("")

      @code_words = []
      custom_barcodes.each do |x|
        @code_words << x
      end

puts @code_words

      sheet = BarcodeSheet.new
      sheet.path = dir_base
      sheet.code_type = type
      sheet.create_pdf_new(self, filename, @code_words)
      return dir_base + filename
    rescue => exc
      logger.error("barcode pdf sheet create failed: " + dir_base + filename)
      logger.info(exc)
      logger.info($@.join("\n"))
      return
  end
end
