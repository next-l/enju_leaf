# -*- encoding: utf-8 -*-
class ZipCodeList < ActiveRecord::Base

  searchable do
    text :prefecture_name, :city_name, :region_name
  end

  public
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

    puts "zip.id=#{zip.id} "

    # whitespece remove
    #address = address.strip_with_full_size_space
    asub = zip.check_include_address(address)
    logger.debug "asub=#{asub}" 
    a2 = address.delete(asub)
    logger.debug "a2=#{a2}"
    puts "a2=#{a2}"

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

    #                 # rule 3
    a5 = a4.gsub(/[^0-9A-Z\-]{1,}/, "-").gsub(/[A-Z]{2,}/, "-")
    logger.debug "rule3-1 a5=#{a5}"

    a5 = a5.gsub(/[-]{2,}/, "-").gsub(/^[-]|[-]$/, "")
    logger.debug "rule3-2 a5=#{a5}"

    code = zip_code + a5

    logger.debug "rule3 end code=#{code}"

    return code
  end

  def check_include_address(address)
    suffix = "丁目"; range_char = "〜"

    puts "address=#{address}"

    if self.flag10 && self.flag10 == 1
      puts "flag10 multiple address"
      self.region_name =~ /(.*)（(.*)#{suffix}）/
      unless $2 
        logger.error "error"
        raise ArgumentError, "trap 1 at check_include_address"
      end
      a = $1.dup

      #puts "$2=#{$2}"
      s = $2.dup.tr("０-９", "0-9")
      s =~ /(\d{1,})#{range_char}(\d{1,})/
      puts "range check $1=#{$1} $2=#{$2}" 
      if $1.present? && $2.present?
        ($1..$2).each do |i|
          asub = self.prefecture_name+self.city_name+a+i.to_s+suffix
          puts asub
          if address.index(asub) == 0
            return self.prefecture_name+self.city_name+a
          end
        end
      end

      raise ArgumentError, "trap 2 at check_include_address"
    else
      asub = self.prefecture_name+self.city_name+self.region_name
      logger.debug "asub1=#{asub}"
      unless address.index(asub) == 0
        logger.info "try matching city+region"
        asub = self.city_name + self.region_name
        logger.debug "asub2=#{asub}"
        unless address.index(asub) == 0
          raise ArgumentError, "trap 3 at check_include_address"
        end
      end
    end

    return asub
  end

  def self.import(filename = nil)
    zipcode_import = self.new
    rows = zipcode_import.open_import_file(filename)
    ZipCodeList.delete_all

    #ZipCodeList.transaction do
      rows.each_with_index do |row, row_num|
        h = {}
        h[:union_code] = row[0]
        h[:zipcode7] = row[2]
        h[:prefectrure_name_kana] = row[3]
        h[:city_name_kana] = row[4]
        h[:region_name_kana] = row[5]
        h[:prefecture_name] = row[6]
        h[:city_name] = row[7]
        h[:region_name] = row[8]
        h[:flag10] = row[9]
        h[:flag11] = row[10]
        h[:flag12] = row[11]
        h[:flag13] = row[12]
        h[:flag14] = row[13]
        h[:update_flag] = row[14]
        ZipCodeList.create!(h)

        if row_num % 200 == 0
          Sunspot.commit
          GC.start
          puts "#{row_num} success."
        end
      end
    #end
    Sunspot.commit

  end

  def open_import_file(upload_file_path)
    tempfile = Tempfile.new('zipcode_import_file')
    #TODO
    open(upload_file_path){|f|
      f.each{|line|
        tempfile.puts(NKF.nkf('-w -Lu', line))
      }
    }
    tempfile.close

    file = CSV.open(tempfile.path, :col_sep => "\t")
    #header = file.first
    #rows = CSV.open(tempfile.path, :headers => header, :col_sep => "\t")
    rows = CSV.open(tempfile.path)

    #ResourceImportResult.create(:resource_import_file => self, :body => header.join("\t"), :error_msg => "HEADER DATA")
    tempfile.close(true)
    file.close
    rows
  end
end
