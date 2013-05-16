# coding: utf-8
require 'ostruct'
class Wareki < ActiveRecord::Base
  attr_accessible :display_name, :note, :short_name, :year_from, :year_to

  validates :display_name, :presence => true
  validates :short_name, :presence => true
  validates :year_from, :numericality => {:only_integer => true}, :allow_blank => false
  validates :year_to, :numericality => {:only_integer => true}, :allow_blank => true

  #see: http://ja.wikipedia.org/wiki/%E5%85%83%E5%8F%B7%E4%B8%80%E8%A6%A7_(%E6%97%A5%E6%9C%AC)
  GENGOUS = {"寛政" => OpenStruct.new({:from=>'17890219', :to=>'18010319'}),
             "享和" => OpenStruct.new({:from=>'18010319', :to=>'18040322'}),
             "文化" => OpenStruct.new({:from=>'18040322', :to=>'18180526'}),
             "文政" => OpenStruct.new({:from=>'18180526', :to=>'18310123'}),
             "天保" => OpenStruct.new({:from=>'18310123', :to=>'18450109'}),
             "弘化" => OpenStruct.new({:from=>'18440109', :to=>'18480401'}),
             "嘉永" => OpenStruct.new({:from=>'18480401', :to=>'18550115'}),
             "安政" => OpenStruct.new({:from=>'18550115', :to=>'18600408'}),
             "万延" => OpenStruct.new({:from=>'18600408', :to=>'18610329'}),
             "文久" => OpenStruct.new({:from=>'18610329', :to=>'18640327'}),
             "元治" => OpenStruct.new({:from=>'18640327', :to=>'18650501'}),
             "慶応" => OpenStruct.new({:from=>'18650501', :to=>'18681023'}),
             "明治" => OpenStruct.new({:from=>'18681023', :to=>'19120730'}),
             "M"    => OpenStruct.new({:from=>'18681023', :to=>'19120730'}),
             "大正" => OpenStruct.new({:from=>'19120730', :to=>'19261225'}),
             "T"    => OpenStruct.new({:from=>'19120730', :to=>'19261225'}),
             "昭和" => OpenStruct.new({:from=>'19261225', :to=>'19890107'}),
             "S"    => OpenStruct.new({:from=>'19261225', :to=>'19890107'}),
             "平成" => OpenStruct.new({:from=>'19890108', :to=>'20991231'}),
             "H"    => OpenStruct.new({:from=>'19890108', :to=>'20991231'}),
            }

  def self.wareki2yyyy(gengou, yy)
    return nil unless GENGOUS.key?(gengou)
    if yy.class == String
      yyi = yy.to_i
    else
      yyi = yy
    end
    #FIXME : なんかうまいこと３項演算子がつかえない
    #return (GENGOUS[gengou].to_i - 1 + (yy.class == String)?(yy.to_i):(yy)) 
    return (GENGOUS[gengou].from[0..3].to_i) - 1 + yyi
  end

  def self.generate_merge_range(pub_date_from_str, pub_date_to_str)
    if pub_date_from_str.present?
      from4, to4 = Wareki.hiduke2yyyymmdd_sub(pub_date_from_str)
    end
    if pub_date_to_str.present?
      from5, to5 = Wareki.hiduke2yyyymmdd_sub(pub_date_to_str)
    end
    from0 = from4
    to0 = (to5.present?)?(to5):(to4)
    return from0, to0
  end

  def self.hiduke2yyyymmdd_sub(datestr)
    yyyymmdd_from = nil 
    yyyymmdd_to = nil 
    dfrom = nil 
    dto = nil

    return nil, nil if datestr.blank?

    orgstr = datestr.dup

    pattern_hash = {"一"=>'1', "二"=>'2', "三"=>'3', "四"=>'4', "五"=>'5',
                    "六"=>'6', "七"=>'7', "八"=>'8', "九"=>'9', "〇"=>'0',
                    "元"=>'1',
                   } 

    datestr.strip!
    datestr.delete!("[]?？()（）") 
    datestr.delete!(" 　")                  # 半角全角スペースを削除 
    datestr = NKF.nkf('-m0Z1 -w', datestr)  # 全角数字を半角に変換
    datestr.gsub!(/[一二三四五六七八九〇元]/, pattern_hash) # 漢数字を半角数字に変換
    datestr.upcase!                         # アルファベット半角小文字を半角大文字に変換
    datestr.gsub!(".", "/")

    begin
      #i = GENGOUS.keys.index(datestr[0, 2])
      headstr = datestr[0, 2]
      i = nil
      GENGOUS.each_with_index do |a, index|
       if headstr.index(a[0]) == 0
         i = index ; break 
       end
      end

      if i.present?
        #puts "i=#{i} key=#{GENGOUS.keys[i]} datestr=#{datestr}"
        datestr.gsub!("年", "/")
        datestr.gsub!("月", "/")
        datestr.gsub!("日", "/")
 
        # 和暦
        if datestr.match(/^(#{GENGOUS.keys[i]})(\d{1,2})\/(\d{1,2})\/(\d{1,2})/)
          #puts "match1 1=#{$1} 2=#{$2} 3=#{$3} 4=#{$4}"
          syyyy = wareki2yyyy($1, $2.to_i)
          dfrom = dto = Date.new(syyyy, $3.to_i, $4.to_i)
        elsif datestr.match(/(#{GENGOUS.keys[i]})(\d{1,2})\/(\d{1,2})/)
          #puts "match1 1=#{$1} 2=#{$2} 3=#{$3} 4=#{$4}"
          syyyy = wareki2yyyy($1, $2)
          dfrom = Date.new(syyyy, $3.to_i)
          dto = Date.new(syyyy, $3.to_i).end_of_month
        elsif datestr.match(/(#{GENGOUS.keys[i]})(\d{1,2})/)
          #puts "match1 1=#{$1} 2=#{$2} 3=#{$3} 4=#{$4}"
          syyyy = wareki2yyyy($1, $2)
          dfrom = Date.new(syyyy)
          dto = Date.new(syyyy).end_of_year
        else
          i = GENGOUS.keys.index(datestr)
          if i.present?
            dfrom = Date.strptime(GENGOUS[datestr].from, '%Y%m%d')
            dto = Date.strptime(GENGOUS[datestr].to, '%Y%m%d')
          else
            puts "format error (2) #{datestr}"
          end
        end
        yyyymmdd_from = dfrom.strftime("%Y%m%d") if dfrom
        yyyymmdd_to = dto.strftime("%Y%m%d") if dto
      elsif datestr.match(/^\d{4}/)
        datestr.gsub!("年", "/")
        datestr.gsub!("月", "/")
        datestr.gsub!("日", "/")
        #puts "datestr=#{datestr}"
        # 西暦
        if datestr.match(/^(\d{4})\/(\d{1,2})\/(\d{1,2})/)
          dfrom = dto = Date.new($1.to_i, $2.to_i, $3.to_i)
        elsif datestr.match(/^(\d{4})\/(\d{1,2})/)
          dfrom = Date.new($1.to_i, $2.to_i)
          dto = Date.new($1.to_i, $2.to_i).end_of_month
        elsif datestr.match(/^(\d{4})/)
          dfrom = Date.new($1.to_i)
          dto = Date.new($1.to_i).end_of_year
        else
          puts "format error (3) #{datestr}"
        end
        yyyymmdd_from = dfrom.strftime("%Y%m%d") if dfrom
        yyyymmdd_to = dto.strftime("%Y%m%d") if dto
      else
        puts "format error (1) #{datestr}"
      end
    rescue
      puts "format error (9) msg=#{$!}"
      puts "datestr=#{datestr}"
      puts $@
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

    datestr.sub!('－', '-')
    datestr.sub!('ー', '-')
    datestr.sub!('〜', '-')
    datestr.sub!('～', '-')
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
