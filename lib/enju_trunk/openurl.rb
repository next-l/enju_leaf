# -*- encoding: utf-8 -*-
#-------------------------------------------
# OpenurlQuerySyntaxErrorクラス
# 文法上の誤りをエラーとする
#-------------------------------------------
class OpenurlQuerySyntaxError < RuntimeError; end
#-------------------------------------------
# Openurlクラス
#-------------------------------------------
class Openurl
  # 一致条件ごとの分類
  MATCH_EXACT = [:ndl_dpid] # 完全一致
  MATCH_PART = [:aulast, :aufirst, :au, :title, :atitle, :jtitle, :btitle, :pub] # 部分一致
  MATCH_AHEAD = [:issn, :isbn, :ndl_jpno] # 前方一致

  # ある項目に対して複数語指定時の検索方法ごとの分類
  LOGIC_MULTI_AND = [:au, :title, :atitle, :jtitle, :btitle, :pub] # AND検索
  LOGIC_MULTI_OR = [:ndl_dpid] # OR検索

  # 桁チェックが必要な項目
  NUM_CHECK = {:issn => 8, :isbn => 13}

  # 集約される項目
  SYNONYMS = [:title, :aulast, :aufirst]

  # enjuのフィールド名（検索用）管理
  ENJU_FIELD = {:aulast => 'au_text', # aulast=au
                :aufirst => 'au_text', # aufirst=au
                :au => 'au_text',
                :title => 'btitle_text',  # title=btitle
                :atitle => 'atitle_text',
                :btitle => 'btitle_text',
                :jtitle => 'jtitle_text',
                :pub => 'publisher_text',
                :issn => 'issn_s',
                :isbn => 'isbn_sm',
                :ndl_jpno => 'ndl_jpno_text', # TODO:現在対応項目はないので保留。
                :ndl_dpid => 'ndl_dpid_sm',   # TODO:現在対応項目はないので保留。これのみ完全一致であることに注意。
                :associate => ''              # TODO:フィールド名ではないので削除？
  }

  def initialize(params)
    # @openurl_queryに検索項目ごとの検索文を格納
    if params.has_key?(:any) then
      # anyの場合は他に条件が指定されていても無視
      @openurl_query = [params[:any].strip]
    else
      @openurl_query = to_sunspot(params)
    end
    @manifestations = []
  end

  attr_reader :openurl_query, :manifestations, :query_text

  # 検索
  def search
    search = Sunspot.new_search(Manifestation)
    @query_text = build_query
    query = @query_text
    search.build{ fulltext query }
    search.execute!.results
  end

  private
  # 検索文を結合,
  def build_query
    @openurl_query.join(" AND ")
  end

  # params OpenURLのリクエストのパラメータ
  # 個々のパラメータに合わせて検索文を組立てメソッドを呼ぶ。この時、引数は、enjuのフィールド名と値。
  def to_sunspot(params)
    query = []
    params.each_key do |key|
      key = key.to_sym
      if MATCH_EXACT.include?(key) then # 完全一致
        query << to_sunspot_match_exact(ENJU_FIELD[key], params[key].strip)
      elsif MATCH_PART.include?(key) then # 部分一致
        query << to_sunspot_match_part(key, ENJU_FIELD[key], params[key].strip)
      elsif MATCH_AHEAD.include?(key) then # 前方一致
        query << to_sunspot_match_ahead(key, ENJU_FIELD[key], params[key].strip)
      end
    end
    # queryにあるau_textの統合
    @openurl_query = unite_au_query(query)
  end

  # 完全一致の項目の検索文組立て
  # TODO 完全一致の項目はndl_dpidだけで、これはデータプロバイダについて議論中なので保留する
  def to_sunspot_match_exact(field, val)
    # 途中に空白がある場合は複数語が指定されているとみなし、ORでつなぐ。
    if /\s+/ =~ val
      "%s:%s" % [field, val.gsub(/\s+/, ' OR ')]
    else
      "%s:%s" % [field, val]
    end
  end

  # 部分一致の項目の検索文組立て
  # key   パラメータのキー（複数指定の検索方法判断に使う）
  # field 項目名
  # val   値
  def to_sunspot_match_part(key, field, val)
    # 途中に空白がある場合は複数語が指定されているとみなし、ANDでつなぐ。
    if /\s+/ =~ val
      if LOGIC_MULTI_AND.include?(key) then
        "%s:(%s)" % [field, val.gsub(/\s+/, ' AND ')]
      else
        raise OpenurlQuerySyntaxError, "the key \"#{key}\" not allow multi words"
      end
    else
      "%s:%s" % [field, val]  # fieldに対して語が１つならばこれ
    end
 end

  # 前方一致の項目の検索文組立て
  def to_sunspot_match_ahead(key, field, val)
    # 既定の桁より大きい場合、または、数値でない文字列の場合エラー
    # 数値でない文字列には空白がある場合も含むので複数指定はエラーとなる
    # このチェックはANY検索の時外す
    if NUM_CHECK.include?(key) then
      if [:issn, :isbn].include?(key.to_sym)
        val.gsub!('-', '')
      end
      raise OpenurlQuerySyntaxError unless /\A\d{1,#{NUM_CHECK[key]}}X?\Z/i =~ val
    end
    "%s:%s*" % [field, val]
  end

  # au項目の統合
  # au、aufirst、aulastはau_textに統合する
  def unite_au_query(query)
    new_query = []
    au_item = []
    str = "au_text:"
    au_flg = false
    reg = Regexp.compile(/\A#{str}/)
    query.each do |q|
      if reg =~ q then
        au_flg = true
        au_item.push(q[str.length..q.length])
      else
        new_query.push(q)
      end
    end
    if au_flg then
      if au_item.size > 1 then
        str = str + "(%s)" % [au_item.join(' AND ')]
      else
        str = str + au_item[0]
      end
      new_query.push(str)
    end
    return new_query
  end
end
