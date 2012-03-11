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
          code = self.generate_japanpost_customer_code(user.patron.zip_code_1, user.patron.address_1)
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

  def self.generate_japanpost_customer_code(zip_code, address)
    # see http://www.post.japanpost.jp/zipcode/zipmanual/p19.html
    sp1 = ["丁目","丁","番地","番","号","地割","線","の","ノ"]

    logger.info "@@@ Start zip_code=#{zip_code} address=#{address}"
    if zip_code.empty? or address.empty?
      raise ArgumentError, "zip_code or address is empty."
    end
    zip_code = zip_code.gsub(/\D/, "")
    unless zip_code.size == 7
      raise ArgumentError, "zip_code is invalid. (size invalid)"
    end
    zip = ZipCodeList.find_by_zipcode7(zip_code)
    unless zip
      raise ArgumentError, "zip_code is invalid. (no record)"
    end

    # whitespece remove
    #address = address.strip_with_full_size_space
    asub = zip.prefecture_name+zip.city_name+zip.region_name
    logger.debug "asub1=#{asub}"
    asub = zip.check_include_address(address)
    
    a2 = address.delete(asub)
    logger.debug "a2=#{a2}"

    # rule 0 wide-char alphabet and numeric convert to ascii 
    a3 = a2.tr('ａ-ｚＡ-Ｚ１-９', 'a-zA-Z1-9')
    
    # rule 1 ascii alphabet small to large
    a3.upcase!

    # rule 2
    spr2 = "&/・."
    a3.gsub!(/"#{spr2}"/, "")
    logger.debug "rule2 end a3=#{a3}"

    # sp1 kanji number to number-char 
    a4 = a3
    sp1.each do |c|

    end

    # rule 3
    a5 = a4.gsub(/[^0-9A-Z\-]{1,}/, "-").gsub(/[A-Z]{2,}/, "-")
    logger.debug "rule3-1 a5=#{a5}"

    a5 = a5.squeeze.gsub(/^[-]|[-]$/, "")

    code = zip_code + a5

    logger.debug "rule3 end code=#{code}"
    
    return code  
  end

  def self.gen_barcode(code)
    logger.info "gen_barcode code=#{code}"

    doc = RGhost::Document.new :paper => ['15 cm', '1 cm']
    doc.barcode_japanpost code, :x => 0, :y => 0, :width => '15 cm', :height => '1 cm'
    io = StringIO.new(doc.render_stream(:png))
    return io.respond_to?(:set_encoding) ? io.set_encoding('UTF-8') : io
 end
end
