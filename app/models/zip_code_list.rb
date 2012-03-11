# -*- encoding: utf-8 -*-
class String 
  def strip_hypen_around_alphabet
    s = ""
    c = 0 
    doFlag = true
    while doFlag
      break if c > self.size
      c2 = c
      c = self.index(/\-[A-Z]/, c) 
      unless c
        s = s + self[c2..-1]
        break 
      end
      s = s + self[0...c] 
      c = c + 1
    end

    # TODO
    return s
  end

  def self.kanju2num(kan)
    nums = %w|〇 一 二 三 四 五 六 七 八 九|
    digits =  %w|十 百 千|
    digits2 = %w|万 億 兆|

    pieces = kan.split(//)
    stack = 0
    sum = 0
    result = 0
    while kan = pieces.shift
      if i = nums.index(kan)
        stack = i
      elsif i = digits.index(kan)
        stack = 1 if stack == 0
        sum += stack * (10 ** (i + 1))
        stack = 0
      elsif i = digits2.index(kan)
        result += (sum + stack) * ( 10 ** ((i + 1) * 4))
        sum = 0
        stack = 0
      end
    end
    result += sum + stack
    return result.to_s
  end
end

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

    #puts "zip.id=#{zip.id} "

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
    a3 = a3.gsub(/[&\/..・]/, "")
    logger.debug "rule2 a3=#{a3}"

    # sp1 kanji number to number-char 
    a4 = a3.dup
    sp1.each do |c|
      logger.debug "a4=#{a4} c=#{c}"
      pos = a4.index(c)
      if pos
        logger.debug "find pos=#{pos}"
        break_flag = false
        rs = ""
        pos2 = pos - 1
        logger.debug "pos2=#{pos2}"
        loop do
          logger.debug "a4=#{a4[pos2]}"
          if a4[pos2] =~ /[一二三四五六七八九十〇]/ 
            rs += a4[pos2]
            logger.debug "append rs=#{rs}"
            if pos2 < 0
              break_flag = true
            end
          else
            break_flag = true
          end

          if break_flag 
            logger.debug "break. pos2=#{pos2} rs=#{rs}"
            if rs.present?
              rs.reverse!
              logger.debug "rs=#{rs}"
              rp = String.kanju2num(rs)
              a4[pos2+1, rs.size] = rp
              logger.debug "a4rp=#{a4}"
            end
            break
          end
          pos2 = pos2 - 1
        end
      end
    end

    # rule 3
    a5 = a4.gsub(/[^0-9A-Z\-]{1,}/, "-").gsub(/[A-Z]{2,}/, "-")
    logger.debug "rule3-1 a5=#{a5}"

    a5 = a5.gsub(/[-]{2,}/, "-").gsub(/^[-]|[-]$/, "")
    logger.debug "rule3-2 a5=#{a5}"
    a5 = a5.strip_hypen_around_alphabet
    logger.debug "rule3-3 a5=#{a5}"

    code = zip_code + a5

    logger.debug "rule3 end code=#{code}"

    return code
  end

  def check_include_address(address)
    suffix = "丁目"; range_char = "〜"

    puts "address=#{address}"
    address = self.build_asub(address)

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
      #puts "range check $1=#{$1} $2=#{$2}" 
      if $1.present? && $2.present?
        ($1..$2).each do |i|
          asub = self.build_asub(self.prefecture_name, self.city_name, a, i.to_s, suffix)
          #puts asub
          if address.index(asub) == 0
            return self.prefecture_name+self.city_name+a
          end
        end
      end

      raise ArgumentError, "trap 2 at check_include_address"
    else
      asub = self.build_asub(self.prefecture_name, self.city_name, self.region_name)
      logger.debug "asub1=#{asub}"
      unless address.index(asub) == 0
        logger.info "try matching city+region"
        asub = self.build_asub(self.city_name, self.region_name)
        logger.debug "asub2=#{asub}"
        unless address.index(asub) == 0
          raise ArgumentError, "trap 3 at check_include_address"
        end
      end
    end

    return asub
  end

  def build_asub(*args)
    asub = args.join
    puts "asub=#{asub} flag11=#{self.flag11}"
    if self.flag11 = 1
      asub = asub.gsub(/大字/, "")
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
