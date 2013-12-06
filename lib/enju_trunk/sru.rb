require 'enju_leaf/porta_cql'

class QueryArgumentError < QueryError; end

class Sru
  ASC_KEYS = %w(title creator) unless Object.const_defined?(:ASC_KEYS)
  DESC_KEYS = %w(created_at updated_at date_of_publication) unless Object.const_defined?(:DESC_KEYS)
  SORT_KEYS = ASC_KEYS + DESC_KEYS unless Object.const_defined?(:SORY_KEYS)
  MULTI_KEY_MAP = {'title' => 'sort_title'} unless Object.const_defined?(:MULTI_KEY_MAP)
  def initialize(params)
    raise QueryArgumentError, 'sru :query is required item.' unless params.has_key?(:query)

    @cql = Cql.new(params[:query])
    @version = params.has_key?(:version) ? params[:version] : '1.2'
    @start = params.has_key?(:startRecord) ? params[:startRecord].to_i : 1
    @maximum = params.has_key?(:maximumRecords) ? params[:maximumRecords].to_i : 200
    @maximum = 1000 if 1000 < @maximum
    @packing = params.has_key?(:recordPacking) ? params[:recordPacking] : 'string'
    @schema = params.has_key?(:recordSchema) ? params[:recordSchema] : 'dc'
    @sort_key = params[:sortKeys]

    @manifestations = []
    @extra_response_data = {}
  end

  attr_reader :version, :cql, :start, :maximum, :packing, :schema, :path, :ascending
  attr_reader :manifestations, :extra_response_data, :number_of_records, :next_record_position

  def sort_by
    sort = {:sort_by => 'created_at', :order => 'desc'}
    unless '1.1' == @version
      @path, @ascending = @cql.sort_by.split('/')
    else
      @path, @ascending = @sort_key.split(',') if @sort_key
    end
    #TODO ソート基準が入手しやすさの場合の処理
    if SORT_KEYS.include?(@path)
      if MULTI_KEY_MAP.keys.include?(@path)
        sort[:sort_by] = MULTI_KEY_MAP[@path]
      else
        sort[:sort_by] = @path
      end
      sort[:order] = 'asc' if ASC_KEYS.include?(@path)
      case @ascending
      when /\A(1|ascending)\Z/
        sort[:order] = 'asc'
      when /\A(0|descending)\Z/
        sort[:order] = 'desc'
      end
    end
    sort
  end

  def search
    sunspot_query = @cql.to_sunspot
    search = Sunspot.new_search(Manifestation)
    search.build do
      fulltext sunspot_query
      paginate :page => 1, :per_page => 10000
    end
    @manifestations = search.execute!.results
    @extra_response_data = get_extra_response_data
    @number_of_records, @next_record_position = get_number_of_records

    @manifestations
  end

  def get_extra_response_data
    #TODO: NDL で必要な項目が決定し、更に enju にそのフィールドが設けられた後で正式な実装を行なう。
    if @search.respond_to?(:erd)
      @schema == 'dc' ? @search.erd : {}
    end
  end

  def get_number_of_records
    #TODO: sunspot での取得方法が分かり次第、正式な実装を行なう。
    @schema == 'dc' ? [1405, 1406] : [40,11]
  end
end

if $PROGRAM_NAME == __FILE__
  require 'sru_test'
end
