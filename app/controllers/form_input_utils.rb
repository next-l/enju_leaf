# encoding: utf-8
module FormInputUtils
  private

  # 入力文字列を整数化する
  # ただし数値を表す文字列でない場合にはnilを返す
  #
  # 使用例:
  #
  #     normalize_integer('10') #=> 10
  #     normalize_integer('010') #=> 10
  #     normalize_integer('a10') #=> nil
  #     normalize_integer('10a') #=> nil
  #     normalize_integer(' 10') #=> 10
  def normalize_integer(form_input)
    text = form_input.to_s
    return nil unless /\A\d+\z/ =~ text

    text.to_i
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
  #
  # 使用例:
  #
  #     each_query_word('foo bar') #=> ["foo", "bar"]
  #     each_query_word('foo "bar baz"') #=> ["foo", "\"bar baz\""]
  #     each_query_word('foo AND bar') #=> ["foo", "\"AND\"", "bar"]
  #     each_query_word('foo AND bar', false) #=> ["foo", "AND", "bar"]
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
  #
  # 使用例:
  #
  #     unquote_query_word(%q<"foo">) #=> "foo"
  #     unquote_query_word(%q<'foo'>) #=> "foo"
  #     unquote_query_word(%q<'foo">) #=> "'foo\""
  #     unquote_query_word(%q<"\\">) #=> "\\"
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

  # Sunspotのfulltextによる検索においては
  # 検索文字列が1文字だけのときにうまく検索できないことがある。
  # これを回避(近似)するためにstringで登録されるインデックスを用いて
  # 1文字検索を行うためのSolr用クエリー文字列を生成する。
  # (fulltextによる検索は、searchableブロックでtextで登録されるインデックスが対象となる。)
  #
  # 引数は次の通り。
  #
  #  * text - 1文字からなる検索文字列を含む文字列
  #  * model - 検索対象とするモデル(クラス)
  #  * string_fields - textで登録される文字列群をカバーするのに十分なstring型のインデックス群
  #
  # 使用例:
  #
  #     generate_adhoc_one_char_query_text('あ い うえお AND "かき くけこ"', Patron, [:full_name, :note])
  #     #=> "{!qf='full_name_s note_s'}*あ* *い* *うえお* *AND* *かき\ くけこ*"
  #
  # 注意:
  # 可能ならば適切なインデックス構成とすることでこうした問題を解決するのが望ましい。
  # しかし、インデックス構成の変更が難しいケースもある。
  # ここでの方法はあくまでadhocなものであり利用を推奨するものではない。
  def generate_adhoc_one_char_query_text(text, model, string_fields)
    model_string_fields = {}
    Sunspot::Setup.for(model).fields.each do |sunspot_field|
      next unless sunspot_field.type.is_a?(Sunspot::Type::StringType)
      model_string_fields[sunspot_field.name] = sunspot_field.indexed_name
    end

    indexed_names = []
    string_fields.each do |field|
      unless model_string_fields.include?(field)
        logger.debug "#{model.name} has no such a string-typed-field: #{field.inspect}"
        next
      end
      indexed_names << model_string_fields[field]
    end

    if indexed_names.blank?
      # 指定されたstring型フィールドのすべてが
      # modelに登録されていなかった
      # (用法の間違いのおそれがある)
      logger.debug "no valid string-typed-filed-names for #{model.name} given (missuse?)"
      return one_char_text
    end

    qwords = []
    each_query_word(text) do |t|
      t = $1.gsub(/(\s)/, '\\\\\\1') if /\A"(.*)"\z/ =~ t
      qwords << "*#{t}*"
    end

    "{!qf='#{indexed_names.join(' ')}'}#{qwords.join(' ')}"
  end
end
