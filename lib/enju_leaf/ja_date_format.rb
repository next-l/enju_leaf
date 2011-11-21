# -*- encoding: utf-8 -*-
module JaDateFormat
  def calc_ja(v)
    year = v.strftime('%Y').to_i
    case year 
    when 0..1925
      return "#{year}年"
    when 1926..1988 
      return '昭和' + "#{year - 25 - 1900}年"
    when 1989
      return '平成元年'
    else 
      return '平成' + "#{year + 12 - 2000}年"
    end
  end

  def ja_wmd(v)
    calc_ja(v) + v.strftime('%m' + '月' + '%d' + '日' )  
  end

end
