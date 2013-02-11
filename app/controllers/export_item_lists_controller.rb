class ExportItemListsController < ApplicationController
  before_filter :check_librarian

  def initialize
    @list_types = [[t('item_list.shelf_list'),1],
                   [t('item_list.call_number_list'), 2],
                   [t('item_list.removed_list'), 3],
                   [t('item_list.unused_list'), 4],
                   [t('item_list.series_statements_list'), 8],
                   [t('item_list.new_item_list'), 5],
                   [t('item_list.latest_list'), 6],
                   [t('item_list.new_book_list'), 7]
                 ]
    @libraries = Library.all
    @carrier_types = CarrierType.all
    @bookstores = Bookstore.all
    @selected_list_type = 1
    @selected_library, @selected_carrier_type, @selected_bookstore = [], [], []
    super
  end

  def index
    @selected_library = @libraries.map(&:id)
    @selected_carrier_type = @carrier_types.map(&:id)
    @selected_bookstore = @bookstores.map(&:id)
    @items_size = Item.count(:all, :joins => [:manifestation, :shelf => :library])
    @page = (@items_size / 36).to_f.ceil
  end

  def create
    # check checked
    @selected_list_type = params[:export_item_list][:list_type]
    @selected_library = params[:library].map(&:to_i) if params[:library]
    @selected_carrier_type = params[:carrier_type].map(&:to_i) if params[:carrier_type]
    @selected_bookstore = params[:bookstore].map(&:to_i) if params[:bookstore]
    booksotre_ids = params[:all_bookstore] == 'true' ? :all : @selected_bookstore

    @ndc = params[:ndc]
    @acquired_at = params[:acquired_at].to_s.dup

    list_type = params[:export_item_list][:list_type].to_i
    file_type = params[:export_item_list][:file_type]

    unless %w(pdf tsv).include?(file_type)
      raise BadParameter, [t('item_list.invalid_file_type')]
    end

    ndcs, acquired_at = parse_list_params(
      @selected_library,
      @selected_carrier_type,
      booksotre_ids,
      @ndc,
      @acquired_at)
    scope, filename = construct_list_query(
      list_type,
      @selected_library,
      @selected_carrier_type,
      booksotre_ids,
      ndcs,
      acquired_at,
      true)

    # make file
    args = []
    case list_type
    when 3
      method = 'make_export_removed_list'
    when 5
      method = 'make_export_new_item_list'
    when 6
      method = 'make_export_series_statements_latest_list'
    when 7
      method = 'make_export_new_book_list'
    when 8
      method = 'make_export_series_statements_list'
      args << acquired_at
    else
      method = 'make_export_item_list'
      args << filename if file_type == 'pdf'
    end

    dumped_scope = Marshal.dump(scope)
    job_name = Item.make_export_item_list_job(filename, file_type, method, dumped_scope, args, current_user)
    flash[:message] = t('item_list.export_job_queued', :job_name => job_name)
    redirect_to export_item_lists_path
    return true

  rescue BadParameter => e
    flash[:message] = e.errors.join('<br />')
    @items_size = 0
    @page = 0
    render :index
    return false

  rescue Exception => e
    logger.error "failed #{e}"
    logger.debug "Exception: #{e.message} (#{e.class})"
    logger.debug "\t" + e.backtrace.join("\n\t")
    render :nothing => true, :status => :internal_server_error
    return false
  end

  def get_list_size
    unless request.xhr? && params[:list_type].present?
      render :nothing => true, :status => :not_found
      return
    end

    list_type = params[:list_type]
    ndcs = params[:ndc]
    libraries = params[:libraries]
    carrier_types = params[:carrier_types]
    bookstores = params[:bookstores]
    acquired_at = params[:acquired_at]
    libraries = libraries.map{|library|library.to_i} if libraries
    carrier_types = carrier_types.map{|carrier_type|carrier_type.to_i} if carrier_types
    bookstores = bookstores.map{|bookstore|bookstore.to_i} if bookstores
    booksotres = params[:all_bookstore] == 'true' ? :all : bookstore

    ndcs, acquired_at = parse_list_params(
      libraries,
      carrier_types,
      booksotres,
      ndcs,
      acquired_at,
      false)
    scope, = construct_list_query(
      list_type.to_i,
      libraries,
      carrier_types,
      booksotres,
      ndcs,
      acquired_at,
      false)

    # list_size
    list_size = scope.count rescue 0

    #page
    page = (list_size / 36).to_f.ceil
    page = 1 if page == 0

    render :json => {:success => 1, :list_size => list_size, :page => page}

  rescue BadParameter => e
    logger.debug e.errors.join(', ')
    render :json => {:success => 1, :list_size => 0, :page => 0}

  rescue Exception => e
    logger.error e
    render :json => {:success => 0, :list_size => 0, :page => 0}
  end

  private

  # パラメータ(文字列)で与えられた条件を解析する。
  # NDCリストと受入日はしかるべき値に変換する。
  def parse_list_params(library_ids, carrier_type_ids, bookstore_ids, ndcs, acquired_at, deny_blank_bookstore_ids = true)
    error = []

    # check required params
    error << t('item_list.no_list_condition') if library_ids.blank? || carrier_type_ids.blank? || (deny_blank_bookstore_ids && bookstore_ids.blank?)

    # check and convert ndc
    unless ndcs.blank? 
      ndcs = ndcs.gsub(' ', '').split(",") 
      ndcs.each do |ndc|
        unless ndc =~ /^\d{3}$/
          logger.error ndc
          error << t('item_list.invalid_ndc')
          break
        end
      end
    end

    # check and convert acquired_at
    unless acquired_at.blank?
      acquired_at = acquired_at.to_s.gsub(/\D/, '')
      begin
        acquired_at = Time.zone.parse(acquired_at).beginning_of_day.utc.iso8601
      rescue
        error << t('item_list.acquired_at_invalid')
      end
    end

    # fail on errors
    raise BadParameter.new(error) unless error.blank?

    [ndcs, acquired_at]
  end

  # 指定されたパラメータに応じて
  # 出力するリストのためのクエリーと、
  # 指定に応じたファイル名を返す
  def construct_list_query(list_type, library_ids, carrier_type_ids, bookstore_ids, ndcs, acquired_at, apply_order)
    scope = Item.scoped

    ti = Item.arel_table
    tc = Checkout.arel_table

    case list_type
    when 1
      scope = scope.
        where_ndcs_libraries_carrier_types(ndcs, library_ids, carrier_type_ids).
        joins(:manifestation, :shelf => :library)
      order = 'libraries.id, manifestations.carrier_type_id, shelves.id, manifestations.ndc'
      filename = t('item_list.shelf_list')

    when 2
      scope = scope.
        joins(:manifestation, :shelf => :library).
        where(["libraries.id in (?) AND manifestations.carrier_type_id in (?)", library_ids, carrier_type_ids])
      order = 'items.call_number'
      filename = t('item_list.call_number_list')

    when 3
      scope = scope.
        joins(:manifestation, :circulation_status, :shelf => :library).
        where(["libraries.id in (?) AND manifestations.carrier_type_id in (?) AND circulation_statuses.name = ?",
              library_ids, carrier_type_ids, 'Removed'])
      order = 'libraries.id, manifestations.carrier_type_id, items.shelf_id, items.item_identifier, manifestations.original_title'
      filename = t('item_list.removed_list')

    when 4
      scope = scope.
        joins(:manifestation, :shelf => :library).
        where("libraries.id in (?) AND manifestations.carrier_type_id in (?)",
              library_ids, carrier_type_ids).
        where(ti[:id].not_in(tc.project(:item_id)))
      order = 'libraries.id, manifestations.carrier_type_id, items.shelf_id, items.item_identifier'
      filename = t('item_list.unused_list')

    when 5
      scope = scope.
        recent.
        where_ndcs_libraries_carrier_types(ndcs, library_ids, carrier_type_ids).
        joins(:manifestation, :shelf => :library)
      order = 'libraries.id, manifestations.carrier_type_id, items.shelf_id, items.item_identifier, manifestations.original_title'
      filename = t('item_list.new_item_list')

    when 6
      tm = Manifestation.arel_table
      tm2 = tm.alias("m2")
      tm3 = tm.alias("m3")
      tm4 = tm.alias("m4")
      ts = SeriesHasManifestation.arel_table
      ts2 = ts.alias("s2")
      te = Exemplify.arel_table

      max_sn_q =
        ts.project(
          ts[:series_statement_id],
          tm2[:id].minimum.as('id')
        ).
          join(tm2).on(
            ts[:manifestation_id].eq(tm2[:id])
          ).
          where(
            ts.from(ts2).
            project('*').
            join(tm3).on(
              ts2[:manifestation_id].eq(tm3[:id])
            ).
            where(
              ts2[:series_statement_id].eq(ts[:series_statement_id]).
              and(tm2[:serial_number].lt(tm3[:serial_number]))
            ).exists.not
          ).
          group(ts[:series_statement_id]).
          as('t')

      max_sn_manifestation_q =
        tm.project('*').
          from(tm4).
          join(ts).on(
            ts[:manifestation_id].eq(tm4[:id])
          ).
          join(max_sn_q).on(
            max_sn_q[:series_statement_id].eq(ts[:series_statement_id]).
            and(
              max_sn_q[:id].eq(tm4[:id])
            )
          ).
          as('m')

      scope = scope.
        joins(
          ti.join(te).on(
            te[:item_id].eq(ti[:id])
          ).
          join(tm).on(
            te[:manifestation_id].eq(tm[:id])
          ).join_sql
        ).
        joins(
          'INNER JOIN ' + max_sn_manifestation_q.to_sql +
          ' ON ' + max_sn_manifestation_q[:id].eq(tm[:id]).to_sql
        ).
        joins(:shelf => :library)
      order = 'libraries.id, items.acquired_at, items.bookstore_id, items.item_identifier, items.id'

      filename = t('item_list.latest_list')

    when 7
      day_ago = Time.zone.now - SystemConfiguration.get("new_book_term").day
      scope = scope.
        where_ndcs_libraries_carrier_types(ndcs, library_ids, carrier_type_ids).
        joins(:manifestation, :shelf => :library).
        where(['manifestations.date_of_publication >= ?', day_ago])
      order = 'libraries.id, manifestations.carrier_type_id, items.shelf_id, items.item_identifier, manifestations.original_title'
      filename = t('item_list.new_book_list')

    when 8
      scope = scope.
        series_statements_item(library_ids, bookstore_ids, acquired_at)
      order = 'libraries.id, items.acquired_at, items.bookstore_id, items.item_identifier, items.id'
      filename = t('item_list.series_statements_list')
    end

    scope = scope.order(order) if apply_order
    [scope, filename]
  end

  class BadParameter < RuntimeError
    def initialize(errors)
      super()
      @errors = errors
    end
    attr_reader :errors
  end
end
