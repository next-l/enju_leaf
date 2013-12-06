# -*- encoding: utf-8 -*-
class UserLabel < ActiveRecord::Base
  def self.output_user_label_pdf(user_ids, output_types)
    report = ThinReports::Report.new :layout => "#{Rails.root.to_s}/app/views/print_labels/patron_label"
    user_ids.each do |user_id|
      user = User.find(user_id)
      report.start_new_page
      if output_types.include?("printed_type_full_name")
        report.page.item(:full_name).value(user.patron.full_name) if user && user.patron
      end
      if output_types.include?("printed_type_address")
        report.page.item(:zip_code).value(user.patron.zip_code_1) if user && user.patron
        report.page.item(:address).value(user.patron.address_1) if user && user.patron
      end
      if output_types.include?("printed_type_postal_barcode")
        logger.info "japan postal customer barcode gen start"
        code = ""
        begin
          code = JppCustomercodeTransfer::ZipCodeList.generate_japanpost_customer_code(user.patron.zip_code_1, user.patron.address_1)
        rescue ArgumentError
          logger.warn "argument error in generate_japanpost_customer_code"
          logger.warn $!
          logger.warn $@
        end
        if code.present?
          report.page.item(:customer_barcode).src(self.gen_barcode(code))
        end
        logger.info "japan postal customer barcode gen end"
      end
    end
    return report
  end

  def self.check_zip

  end

  def self.gen_barcode(code)
    logger.info "gen_barcode code=#{code}"

    doc = RGhost::Document.new :paper => ['15 cm', '1 cm']
    doc.barcode_japanpost code, :x => 0, :y => 0, :width => '15 cm', :height => '1 cm'
    io = StringIO.new(doc.render_stream(:png))
    return io.respond_to?(:set_encoding) ? io.set_encoding('UTF-8') : io
 end
end
