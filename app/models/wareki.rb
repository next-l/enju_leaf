class Wareki < ActiveRecord::Base
  attr_accessible :display_name, :note, :short_name, :year_from, :year_to

  validates :display_name, :presence => true
  validates :short_name, :presence => true
  validates :year_from, :numericality => {:only_integer => true}, :allow_blank => false
  validates :year_to, :numericality => {:only_integer => true}, :allow_blank => true

  GENGOUS = {"明治"=>1868,"大正"=>1912,"昭和"=>1926,"平成"=>1989}
  def self.wareki2yyyy(gengou, yy)
    return nil unless GENGOUS.key?(gengou)
    if yy.class == String
      yyi = yy.to_i
    else
      yyi = yy
    end
    #FIXME : なんかうまいこと３項演算子がつかえない
    #return (GENGOUS[gengou].to_i - 1 + (yy.class == String)?(yy.to_i):(yy)) 
    return GENGOUS[gengou].to_i - 1 + yyi
  end

  def self.hiduke2yyyymmdd_sub(datestr)
    yyyymmdd_from = nil 
    yyyymmdd_to = nil 
    dfrom = nil 
    dto = nil

    datestr.strip!
    #puts "datestr=#{datestr}"
 
    i = GENGOUS.keys.index(datestr[0, 2])
    if i.present?
      # 和暦
      if datestr.match(/(#{GENGOUS.keys[i]})(\d{1,2})年$/)
        #puts "match1 #{datestr} 1=#{$1} 2=#{$2} 3=#{$3} 4=#{$4}"
        syyyy = wareki2yyyy($1, $2)
        dfrom = Date.new(syyyy)
        dto = Date.new(syyyy).end_of_year
        #puts "match1 dfrom=#{dfrom} dto=#{dto}"
      elsif datestr.match(/(#{GENGOUS.keys[i]})(\d{1,2})年(\d{1,2})月$/)
        #puts "match2 #{datestr} 1=#{$1} 2=#{$2} 3=#{$3} 4=#{$4}"
        syyyy = wareki2yyyy($1, $2)
        dfrom = Date.new(syyyy, $3.to_i)
        dto = Date.new(syyyy, $3.to_i).end_of_month
        #puts "match2 dfrom=#{dfrom} dto=#{dto}"
      elsif datestr.match(/(#{GENGOUS.keys[i]})(\d{1,2})年(\d{1,2})月(\d{1,2})日$/)
        #puts "match3 #{datestr} 1=#{$1} 2=#{$2} 3=#{$3} 4=#{$4}"
        syyyy = wareki2yyyy($1, $2.to_i)
        dfrom = dto = Date.new(syyyy, $3.to_i, $4.to_i)
        #puts "match3 dfrom=#{dfrom} dto=#{dto}"
      else
        puts "format error (2) #{datestr}"
      end
      yyyymmdd_from = dfrom.strftime("%Y%m%d") if dfrom.present?
      yyyymmdd_to = dto.strftime("%Y%m%d") if dto.present?
    elsif datestr.match(/^\d{4}/)
      # 西暦
      if datestr.match(/^(\d{4})$/)
        #puts "matchy1 #{datestr} 1=#{$1} 2=#{$2} 3=#{$3}"
        dfrom = Date.new($1.to_i)
        dto = Date.new($1.to_i).end_of_year
        #puts "matchy1 dfrom=#{dfrom} dto=#{dto}"
      elsif datestr.match(/^(\d{4})\/(\d{1,2})$/)
        #puts "matchy2 #{datestr} 1=#{$1} 2=#{$2} 3=#{$3}"
        dfrom = Date.new($1.to_i, $2.to_i)
        dto = Date.new($1.to_i, $2.to_i).end_of_month
        #puts "matchy2 dfrom=#{dfrom} dto=#{dto}"
      elsif datestr.match(/^(\d{4})\/(\d{1,2})\/(\d{1,2})$/)
        #puts "matchy3 #{datestr} 1=#{$1} 2=#{$2} 3=#{$3}"
        dfrom = dto = Date.new($1.to_i, $2.to_i, $3.to_i)
        #puts "matchy3 dfrom=#{dfrom} dto=#{dto}"
      else
        puts "format error (3) #{datestr}"
      end
      yyyymmdd_from = dfrom.strftime("%Y%m%d") if dfrom.present?
      yyyymmdd_to = dto.strftime("%Y%m%d") if dto.present?
    else
      puts "format error (1) #{datestr}"
    end
    return yyyymmdd_from, yyyymmdd_to
  end

  def self.hiduke2yyyymmdd(datestr)
    # 西暦もしくは和暦をYYYYMMDD(from,to)の範囲に変換する。
    # 半角のハイフンが存在する場合は範囲として認識する。
    # 一致しない場合は、nil,nil を返す
    # 昭和49年 => 19740101,19741231
    # 昭和49年3月 => 19740301,19740331
    # 昭和49年3月9日 => 19740309,19740309
    # 昭和49年 - 昭和50年 => 19740101,19751231
    # 昭和49年3月9日 - 昭和54年8月4日 => 19740309,19790804
    # 1974 => 19740101,19741231
    # 1974/3/9 - 1975/8/4 => 19740309,19790804
    return nil, nil if datestr.blank?
    yyyymmdd_from = nil 
    yyyymmdd_to = nil 
    from0, to0, from1, to1 = nil, nil, nil, nil

    datestrs = datestr.split('-')
    #puts "datestr0=#{datestrs[0]} datestr1=#{datestrs[1]}"
    from0, to0 = hiduke2yyyymmdd_sub(datestrs[0])
    from1, to1 = hiduke2yyyymmdd_sub(datestrs[1]) if datestrs[1].present?

    yyyymmdd_from = from0
    yyyymmdd_to = to0
    yyyymmdd_to = to1 if datestrs[1].present?

    return yyyymmdd_from, yyyymmdd_to
  end

end
