# encoding: utf-8
module FormInputUtils
  private

  # 入力文字列を整数化する
  # ただし数値を表す文字列でない場合にはnilを返す
  def normalize_integer(form_input)
    Integer(form_input.to_s) rescue nil
  end

  # 以下の前処理を加えた新しい文字列を返す
  #  * いわゆる全角空白文字をASCII空白文字("\x20")に変換する
  #  * 連続する空白文字を一つの空白文字に変換する
  #  * 文字列の先頭と末尾の空白文字を削除する
  def normalize_query_string(form_input)
    form_input.to_s.gsub(/[　\s]+/, ' ').strip
  end

  # 空白を含まない文字列、"..."、'...'を抽出する
  # ただし単独のAND、ORは"AND"、"OR"に変換して返す(quote_op == trueのとき)
  # ブロックが与えられていれば抽出した文字列に適用する
  def each_query_word(str, quote_op = true)
    ary = []
    str = normalize_query_string(str)
    str.scan(/([^"'\s]\S*|(["'])(?:(?:\\\\)+|\\\2|.)*?\2)/) do
      word = $1
      word = "\"#{word}\"" if quote_op && /\A(?:and|or)\z/io =~ word
      ary << word
      yield(word) if block_given?
    end
    ary
  end

  # "..."、'...'から先頭と末尾の「"」「'」を除いた文字列を返す
  # 文字列中の「\"」は「"」に変換する
  def unquote_query_word(word)
    word.sub(/(["'])(.*)\1/, '\\2').gsub(/\\(.)/, '\\1')
  end

  # 二つの日にち(文字列)から
  # 日時範囲の始端と終端を生成して返す。
  # 始端または終端の指定がないときには
  # それぞれnilを返す。
  def construct_time_range(date_from, date_to)
    d1, g1 = parse_date_string(date_from)
    d2, g2 = parse_date_string(date_to)

    d1, g1, d2, g2 = d2, g2, d1, g1 if d1 && d2 && d1 > d2

    if d1
      r_begin = d1.beginning_of_day.utc
    else
      r_begin = nil
    end

    case g2
    when :day
      d2 = d2.end_of_day
    when :month
      d2 = d2.end_of_month
    when :year
      d2 = d2.end_of_year
    end

    if d2
      r_end = d2.utc
    else
      r_end = nil
    end

    [r_begin, r_end]
  end

  # 日にちを示す文字列を解析して
  # 解析できた時刻とそのレベル(:day、:month、:year)を返す
  def parse_date_string(date_str)
    return [nil, nil] if date_str.blank?

    begin
      time = Time.zone.parse(date_str)
      return [time, time ? :day : nil]
    rescue ArgumentError
    end

    dary = date_str.scan(/\d+/)[0, 3].compact # 先頭から三つの数字のかたまりを抽出
    return [nil, nil] if dary.blank?

    if dary.size == 1
      # 数字のかたまりが一つだけの場合「YYYYMMDD」の形式を検討する
      m = dary.first.match(/(\d{1,4})(\d{2})?(\d{2})?/)
      dary = [m[1], m[2], m[3]].compact
    end

    case dary.size
    when 1
      guess = :year
      time = Time.zone.local(dary.first.to_i)
    when 2
      guess = :month
      time = Time.zone.local(*dary.map(&:to_i))
    when 3
      guess = :day
      time = Time.zone.local(*dary.map(&:to_i))
    end

    [time, guess]
  end
end
