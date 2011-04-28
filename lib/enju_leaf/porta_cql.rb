require 'strscan'

class QueryError < RuntimeError; end
class QuerySyntaxError < QueryError; end

class Cql
  def initialize(line)
    @logic = nil
    @query = split_clause_text(line).collect{|txt| Clause.new(txt)}

    from_day, @query = extract_with_index(@query, /from/io)
    @from = comp_date(from_day)
    until_day, @query = extract_with_index(@query, /until/io)
    @until = comp_date(until_day)
    sort_by, @query = extract_with_index(@query, /sortBy/io)
    @sort_by = sort_by ? sort_by.terms.first : ''
  end

  attr_reader :query, :from, :until, :sort_by, :logic

  def ==(other)
    instance_variables.all? do |val|
      instance_variable_get(val) == other.instance_variable_get(val)
    end
  end

  def to_sunspot
    (@query.collect{|c| c.to_sunspot} + date_range(@from, @until)).join(" #{@logic} ")
  end

  def split_clause_text(line)
    clauses = []

    s = StringScanner.new(line)
    text = ''
    while s.rest?
      case
      when s.scan(/\s+/)
        text << s.matched
      when s.scan(/"(?:[^"\\]|\\.)*"/)
        text << s.matched
      when s.scan(/(AND|OR)/i)
        logic = s.matched.upcase
        if @logic
          raise QuerySyntaxError unless @logic == logic
        else
          @logic = logic
        end
        clauses << text.strip
        text = ''
      when s.scan(/\S*/)
        text << s.matched
      end
    end
    clauses << text.strip
    clauses.collect{|txt| txt.gsub(/(\A\(|\)\Z)/, '')}
  end

  private
  def extract_with_index(arr, reg)
    element, rest = arr.partition{|c| reg =~ c.index }
    [element.last, rest]
  end

  def date_range(from_date, until_date)
    unless from_date == '*' and until_date == '*'
      ["date_of_publication_d:[#{from_date} TO #{until_date}]"]
    else
      []
    end
  end

  def comp_date(date)
    if date
      text = date.terms[0]
      date_text = case text
      when /\A\d{4}-\d{2}-\d{2}\Z/
        text
      when /\A\d{4}-\d{2}\Z/
        (text + '-01')
      when /\A\d{4}\Z/
        (text + '-01-01')
      else
        raise QuerySyntaxError, "#{text}"
      end
      begin
        Time.zone.parse(date_text).utc.iso8601.to_s
      rescue
        raise QuerySyntaxError, "#{date}"
      end
    else
      '*'
    end
  end
end

class ScannerError < QuerySyntaxError; end
class AdapterError < QuerySyntaxError; end

class Clause
  INDEX = /(dpid|dpgroupid|title|creator|publisher|ndc|description|subject|isbn|issn|jpno|from|until|anywhere|porta_type|digitalize_type|webget_type|payment_type|ndl_agent_type|ndlc|itemno)/io
  SORT_BY = /sortBy/io
  RELATION = /(=|exact|\^|any|all)/io

  MATCH_ALL = %w[title creator publisher]
  MATCH_EXACT = %w[dpid dpgroupid isbn issn jpno porta_type digitalize_type webget_type payment_type ndl_agent_type itemno]
  MATCH_PART = %w[description subject]
  MATCH_AHEAD = %w[ndc ndlc]
  MATCH_DATE = %w[from until]
  MATCH_ANYWHERE = %w[anywhere]
  LOGIC_ALL = %w[title creator publisher description subject anywhere]
  LOGIC_ANY = %w[dpid ndl_agent_type]
  LOGIC_EQUAL = %w[dpgroupid ndc isbn issn jpno from until porta_type digitalize_type webget_type payment_type ndlc itemno]
  MULTIPLE = %w[dpid title creator publisher description subject anywhere ndl_agent_type]

  def initialize(text)
    unless text.empty?
      @index, @relation, @terms = scan(text)
      porta_adapter
      @field = @index
    else
      @index = ''
    end
  end

  attr_reader :index, :relation, :terms

  def ==(other)
    instance_variables.all? do |val|
      instance_variable_get(val) == other.instance_variable_get(val)
    end
  end

  def scan(text)
    ss = StringScanner.new(text)
    index = ''
    relation = ''
    terms = []

    if ss.scan(INDEX) or ss.scan(SORT_BY)
      index = ss[0]
    end
    #else
    #  raise ScannerError, "index or the sortBy is requested in '#{text}'"
    #end
    ss.scan(/\s+/)
    if ss.scan(RELATION)
      relation = ss[0].upcase
    end
    #else
    #  raise ScannerError, "relation is requested in '#{text}'"
    #end
    ss.scan(/\s+/)
    if ss.scan(/.+/)
      terms = ss[0].gsub(/(\A\"|\"\Z)/, '').split
    else
      raise ScannerError, "search term(s) is requested in '#{text}'"
    end

    [index, relation, terms]
  end

  def porta_adapter
    logic_adapter
    multiple_adapter
  end

  def logic_adapter
    case
    when LOGIC_ALL.include?(@index)
      raise AdapterError unless %w[ALL ANY = EXACT ^].include?(@relation)
    when LOGIC_ANY.include?(@index)
      raise AdapterError unless %w[ANY =].include?(@relation)
    when LOGIC_EQUAL.include?(@index)
      raise AdapterError unless %w[=].include?(@relation)
    end
  end

  def multiple_adapter
    unless MULTIPLE.include?(@index)
      raise AdapterError if @terms.size > 1
    end
  end

  def to_sunspot
    case
    when MATCH_ALL.include?(@index)
      to_sunspot_match_all
    when MATCH_EXACT.include?(@index)
      to_sunspot_match_exact
    when MATCH_PART.include?(@index)
      to_sunspot_match_part
    when MATCH_AHEAD.include?(@index)
      to_sunspot_match_ahead
    when MATCH_ANYWHERE.include?(@index)
      to_sunspot_match_anywhere
    when @index.empty?
      @terms.join(' ')
    end
  end

  def to_sunspot_match_all
    term = @terms.join(' ')
    case @relation
    when /\A=\Z/
      unless /\A\^(.+)/ =~ term
        "%s_%s:(%s)" % [@field, :text, term]
      else
        ahead_tarm = $1.gsub("\s", '').downcase
        "connect_%s_%s:(%s*)" % [@field, :s, ahead_tarm]
      end
    when /\AEXACT\Z/
      "%s_%s:(%s)" % [@field, :sm, term.gsub(' ', '')]
    when /\AANY\Z/
      "%s_%s:(%s)" % [@field, :text, multiple_to_sunspot(@terms, :any)]
    when /\AALL\Z/
      "%s_%s:(%s)" % [@field, :text, multiple_to_sunspot(@terms, :all)]
    else
      raise QuerySyntaxError
    end
  end

  def to_sunspot_match_exact
    case @relation
    when /\A=\Z/
      term = @terms.join(' ')
      type = @field != 'issn' ? :sm : :s
      "%s_%s:(%s)" % [@field, type, term]
    when /\AANY\Z/
      "%s_%s:(%s)" % [@field, :sm, multiple_to_sunspot(@terms, :any)]
    else
      raise QuerySyntaxError
    end
  end

  def to_sunspot_match_part
    case @relation
    when /\A=\Z/
      term = @terms.join(' ')
      "%s_%s:(%s)" % [@field, :text, trim_ahead(term)]
    when /\AANY\Z/
      "%s_%s:(%s)" % [@field, :text, multiple_to_sunspot(@terms, :any)]
    when /\AALL\Z/
      "%s_%s:(%s)" % [@field, :text, multiple_to_sunspot(@terms, :all)]
    else
      raise QuerySyntaxError
    end
  end

  def to_sunspot_match_ahead
    "%s_%s:(%s*)" % [@field, :s, @terms.first]
  end

  def to_sunspot_match_anywhere
    case @relation
    when /\A=\Z/
      term = @terms.join(' ')
      "(%s)" % [trim_ahead(term)]
    when /\AANY\Z/
      "(%s)" % [multiple_to_sunspot(@terms, :any)]
    when /\AALL\Z/
      "(%s)" % [multiple_to_sunspot(@terms, :all)]
    else
      raise QuerySyntaxError
    end
  end


  private
  def multiple_to_sunspot(terms, relation)
    boolean = relation == :any ? ' OR ' : ' AND '
    "#{terms.map{|t| trim_ahead(t)}.join(boolean)}"
  end

  def trim_ahead(term)
    term.sub(/\A\^+/,'')
  end
end

if $PROGRAM_NAME == __FILE__
  require 'porta_cql_test'
end
