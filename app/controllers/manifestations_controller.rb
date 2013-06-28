# -*- encoding: utf-8 -*-
class ManifestationsController < ApplicationController
  add_breadcrumb "I18n.t('breadcrumb.search_manifestations')", 'manifestations_path', :only => [:index] #, :unless => proc{params}
#  add_breadcrumb "I18n.t('breadcrumb.search_manifestations')", 'manifestations_path(params)', :only => [:index], :if => proc{params}
  add_breadcrumb "I18n.t('page.showing', :model => I18n.t('activerecord.models.manifestation'))", 'manifestation_path(params[:id])', :only => [:show]
  add_breadcrumb "I18n.t('page.new', :model => I18n.t('activerecord.models.manifestation'))", 'new_manifestation_path', :only => [:new, :create]
  add_breadcrumb "I18n.t('page.edit', :model => I18n.t('activerecord.models.manifestation'))", 'edit_manifestation_path(params[:id])', :only => [:edit, :update]
  load_and_authorize_resource :except => [:index, :output_show, :output_pdf]
  authorize_resource :only => :index
  before_filter :authenticate_user!, :only => :edit
  before_filter :get_patron
  helper_method :get_manifestation, :get_subject
  before_filter :get_series_statement, :only => [:index, :new, :edit]
  before_filter :prepare_options, :only => [:new, :edit]
  helper_method :get_libraries
  before_filter :get_version, :only => [:show, :output_show, :output_pdf]
  after_filter :solr_commit, :only => [:create, :up, :outputdate, :destroy]
  after_filter :convert_charset, :only => :index
  cache_sweeper :manifestation_sweeper, :only => [:create, :update, :destroy]
  include EnjuOai::OaiController if defined?(EnjuOai)
  include EnjuSearchLog if defined?(EnjuSearchLog)
  include ApplicationHelper
  include ManifestationsHelper

  # GET /manifestations
  # GET /manifestations.json
  def index
    if current_user.try(:has_role?, 'Librarian') && params[:user_id]
      @reserve_user = User.find(params[:user_id]) rescue current_user
    else
      @reserve_user = current_user
    end

    search_opts = {}

    @seconds = Benchmark.realtime do
      # prepare: mode
      if params[:mode] == 'add'
        search_opts[:add_mode] = true
        unless current_user.has_role?('Librarian')
          access_denied
          return
        end
        @add = true
      end

      case params[:format]
      when 'oai'
        search_opts[:oai_mode] = true
        @oai = check_oai_params(params)
        next if @oai[:need_not_to_search]
      when 'sru'
        search_opts[:sru_mode] = true
        unless params[:operation] == 'searchRetrieve'
          render :template => 'manifestations/explain', :layout => false
          return
        end
      end

      if params[:api] == 'openurl'
        search_opts[:openurl_mode] = true
      end

      if params[:output_pdf] || params[:output_tsv] ||
          params[:output_excelx] || params[:output_request]
        search_opts[:output_mode] = true
        search_opts[:output_type] =
          case
          when params[:output_pdf]; :pdf
          when params[:output_tsv]; :tsv
          when params[:output_excelx]; :excelx
          when params[:output_request]; :request
          end
      end

      if params[:format].blank? || params[:format] == 'html'
        search_opts[:html_mode] = true
        search_opts[:solr_query_mode] = true if params[:solr_query].present?
      end

      if params[:item_identifier].present?
        unless params[:item_identifier] =~ /\*/
          search_opts[:direct_mode] = true
        end
      end
      if SystemConfiguration.get("manifestation.isbn_unique") and params[:isbn].present?
        unless params[:isbn] =~ /\*/
          search_opts[:direct_mode] = true
        end
      end

      if defined?(EnjuBookmark) && params[:view] == 'tag_cloud'
        search_opts[:tag_cloud_mode] = true
      end

      # prepare: split option
      if [:oai_mode, :tag_cloud_mode, :sru_mode, :output_mode].all? {|m| !search_opts[m] }
        search_opts[:split_by_type] = SystemConfiguration.get('manifestations.split_by_type')
      end
      if search_opts[:split_by_type]
        if params[:without_article]
          search_opts[:with_article] = false
        else
          search_opts[:with_article] = !SystemConfiguration.isWebOPAC || clinet_is_special_ip?
        end
      end

      # action: oai GetRecord
      if search_opts[:oai_mode] &&
          params[:verb] == 'GetRecord' and params[:identifier]
        begin
          @manifestation = Manifestation.find_by_oai_identifier(params[:identifier])
          render :template => 'manifestations/show', :formats => :oai, :layout => false
        rescue ActiveRecord::RecordNotFound
          @oai[:errors] << "idDoesNotExist"
          render :template => 'manifestations/index', :formats => :oai, :layout => false
        end
        return
      end

      # prepare: per_page
      if params[:format] == 'csv'
        per_page = 65534
      elsif per_pages
        per_page = per_pages[0]
      end
      per_page = cookies[:per_page] if cookies[:per_page] # XXX: セッションデータに格納してはダメ?
      per_page = params[:per_page] if params[:per_page]#Manifestation.per_page

      cookies.permanent[:per_page] = { :value => per_page } # XXX: セッションデータに格納してはダメ?
      search_opts[:per_page] = per_page
      @per_page = per_page

      # prepare: page
      if search_opts[:oai_mode]
        page = next_page_number_for_oai_search
      else
        page = params[:page].try(:to_i) || 1
        page_article = params[:page_article].try(:to_i) || 1
      end

      # prepare: initialize ivars
      @count = {}
      set_reservable
      get_manifestation
      get_subject
      set_in_process
      @index_patron = get_index_patron
      @query = params[:query] # main query string
      @solr_query = params[:solr_query]
      @all_manifestations = params[:all_manifestations] if params[:all_manifestations]

      @libraries = Library.real.all
      @search_engines = Rails.cache.fetch('search_engine_all') { SearchEngine.all }

      if params[:bookbinder_id]
        @binder = Item.find(params[:bookbinder_id]) rescue nil
      end

      if params[:removed_from].present? || params[:removed_to].present? || params[:removed]
        @removed = true
      end

      # action in the following:

      # search a particular manifestation
      if search_opts[:direct_mode]
        manifestation = nil
        if params[:item_identifier].present?
          item = Item.find_by_item_identifier(params[:item_identifier])
          manifestation = item.manifestation if item
        end
        if SystemConfiguration.get("manifestation.isbn_unique") and params[:isbn].present?
          manifestation = Manifestation.where(:isbn => params[:isbn]).first
        end
        if manifestation
          redirect_to manifestation; return
        end
      end

      # setup solr query
      if search_opts[:sru_mode]
        sru = Sru.new(params)
        query = sru.cql.to_sunspot
        sort = sru.sort_by
      elsif search_opts[:openurl_mode]
        openurl = Openurl.new(params)
        query = openurl.query_text
        sort = search_result_order(params[:sort_by], params[:order])
      else
        if search_opts[:solr_query_mode]
          query = @solr_query
        else
          query, highlight = make_query_string_and_hl_pattern
          @solr_query ||= query
          @highlight = /(#{Regexp.union(highlight)})/
        end
        sort = search_result_order(params[:sort_by], params[:order])
      end
      search_opts[:with_periodical_item] = params[:with_periodical_item]
      with_filter, without_filter = make_query_filter(search_opts)

      # build search
      searchs = []
      searchs << search_all = Sunspot.new_search(Manifestation)
      if search_opts[:split_by_type]
        searchs << search_book = Sunspot.new_search(Manifestation).tap do |s|
          s.build { with(:is_article).equal_to false }
        end
        if search_opts[:with_article]
          searchs << search_article = Sunspot.new_search(Manifestation).tap do |s|
            s.build { with(:is_article).equal_to true }
          end
        end
      end
      logger.debug "  SOLR Query string:<#{query}>"

      searchs.each do |s|
        Manifestation.build_search_for_manifestations_list(s, query, with_filter, without_filter)

        unless search_opts[:add_mode]
          includes = [
            :carrier_type, :required_role, :items, :creators, :contributors,
            :publishers,
          ]
          includes << :bookmarks if defined?(EnjuBookmark)
          s.data_accessor_for(Manifestation).include = includes
        end

        s.build do
          if search_opts[:oai_mode]
            order_by :updated_at, :desc
          else
            order_by sort[:sort_by], sort[:order]
            order_by :created_at, :desc
          end
          facet :reservable
        end

        if search_opts[:html_mode] && params[:missing_issue].nil?
          s.data_accessor_for(Manifestation).select = [
            :id, :original_title, :title_transcription, :required_role_id,
            :manifestation_type_id, :carrier_type_id, :access_address,
            :volume_number_string, :issue_number_string, :serial_number_string,
            :date_of_publication, :pub_date, :periodical_master, :language_id,
            :carrier_type_id, :created_at, :note, :missing_issue, :article_title,
            :start_page, :end_page, :exinfo_1, :exinfo_6
          ]
        end
      end

      # file output
      if search_opts[:output_mode]
        # TODO: 第一引数にparamsまたは生成した検索語、フィルタ指定を渡すようにして、バックグラウンドファイル生成で一時ファイルを作らなくて済むようにする
        summary = @query.present? ? "#{@query} " : ""
        summary += advanced_search_condition_summary
        Manifestation.generate_manifestation_list(search_all, search_opts[:output_type], current_user, summary, params[:cols]) do |output|
          send_opts = {
            :filename => output.filename,
            :type => output.mime_type || 'application/octet-stream',
          }
          case output.result_type
          when :path
            send_file output.path, send_opts
          when :data
            send_data output.data, send_opts
          when :delayed
            flash[:message] = t('manifestation.output_job_queued', :job_name => output.job_name)
            redirect_to manifestations_path(params.dup.tap {|h| h.delete_if {|k, v| /\Aoutput_/ =~ k} })
          else
            raise 'unknown result type (bug?)'
          end
        end
        return 
      end

      # search for facet pane
      begin
        all_result = search_all.execute
      rescue Exception => e
        flash[:message] = t('manifestation.invalid_query')
        logger.error "query error: #{e}"
        return
      end
      @reservable_facet = all_result.facet(:reservable).rows

      if session[:search_params]
        unless search_all.query.to_params == session[:search_params]
          clear_search_sessions
        end
      else
        clear_search_sessions
        session[:params] = params
        session[:search_params] = search_all.query.to_params
        session[:query] = search_opts[:solr_query_mode] ? @solr_query : @query
      end

      unless session[:manifestation_ids]
        # FIXME?
        # session[:manifestation_ids]は検索結果の書誌情報を次々と見るのに使われている
        # (manifestations/index→manifestations/show→manifestations/show→...)。
        # よって文献とその他を分ける場合には、このデータも分けて取りまわす必要があるはず。
        manifestation_ids = search_all.build do
          paginate :page => 1, :per_page => SystemConfiguration.get("max_number_of_results")
        end.execute.raw_results.map {|r| r.primary_key.to_i }
        session[:manifestation_ids] = manifestation_ids
      end

      if search_opts[:tag_cloud_mode] && session[:manifestation_ids]
        bookmark_ids = Bookmark.where(:manifestation_id => session[:manifestation_ids]).limit(1000).select(:id).collect(&:id)
        @tags = Tag.bookmarked(bookmark_ids)
        render :partial => 'manifestations/tag_cloud'
        #session[:manifestation_ids] = nil
        return
      end

      if search_opts[:sru_mode]
        search_all.query.start_record(params[:startRecord] || 1, params[:maximumRecords] || 200)

      else
        searchs.each do |s|
          s.build do
            facet :reservable
            facet :carrier_type
            facet :library
            facet :language
            facet :subject_ids
            facet :manifestation_type
            facet :missing_issue
            facet :in_process
            facet :circulation_status_in_process
            facet :circulation_status_in_factory

            if s == search_article
              paginate :page => page_article, :per_page => per_page
            else
              paginate :page => page, :per_page => per_page
            end
          end
        end

        search_all.build do
          spellcheck :collate => 3, :q => params[:query] if search_opts[:html_mode]
        end
      end

      # execute search
      begin
        search_all_result = search_all.execute
        search_book_result = search_book.try(:execute)
        search_article_result = search_article.try(:execute)
      rescue Exception => e
        flash[:message] = t('manifestation.invalid_query')
        logger.error "query error: #{e}"
        return
      end


      @count[:query_result] = search_all_result.total
      @collation = search_all_result.collation if @count[:query_result] == 0

      @manifestations = Kaminari.paginate_array(
        search_all_result.results,
        :total_count => total_search_result_count(search_all_result)
      ).page(page).per(per_page)

      save_search_history(query, @manifestations.limit_value, @count[:query_result], current_user)

      if search_book_result.blank? && search_article_result.blank?
        @manifestations_all = [@manifestations]

      elsif search_book_result
        @manifestations_book = Kaminari.paginate_array(
          search_book_result.results,
          :total_count => total_search_result_count(search_book_result)
        ).page(page).per(per_page)
        @manifestations_all = [@manifestations_book]
      end

      if search_article_result
        @manifestations_article = Kaminari.paginate_array(
          search_article_result.results,
          :total_count => total_search_result_count(search_article_result)
        ).page(page_article).per(per_page)
        @manifestations_all << @manifestations_article
      end

      if search_opts[:html_mode]
        unless search_opts[:with_article]
          @carrier_type_facet = search_book_result.facet(:carrier_type).rows
          @language_facet = search_book_result.facet(:language).rows
          @library_facet = search_book_result.facet(:library).rows
          @manifestation_type_facet = search_book_result.facet(:manifestation_type).rows
          @missing_issue_facet = search_book_result.facet(:missing_issue).rows
          @in_process_facet = search_book_result.facet(:in_process).rows
          @circulation_status_in_process_facet = search_book_result.facet(:circulation_status_in_process).rows
          @circulation_status_in_factory_facet = search_book_result.facet(:circulation_status_in_factory).rows
        else
          @carrier_type_facet = search_all_result.facet(:carrier_type).rows
          @language_facet = search_all_result.facet(:language).rows
          @library_facet = search_all_result.facet(:library).rows
          @manifestation_type_facet = search_all_result.facet(:manifestation_type).rows
          @missing_issue_facet = search_all_result.facet(:missing_issue).rows
          @in_process_facet = search_all_result.facet(:in_process).rows
          @circulation_status_in_process_facet = search_all_result.facet(:circulation_status_in_process).rows
          @circulation_status_in_factory_facet = search_all_result.facet(:circulation_status_in_factory).rows
        end
      end

      # TODO: 検索結果が少ない場合にも表示させる
      if manifestation_ids.blank? &&
          defined?(EnjuBookmark) &&
          query.respond_to?(:suggest_tags)
        @suggested_tag = query.suggest_tags.first
      end
    end
    store_location # before_filter ではファセット検索のURLを記憶してしまう
    respond_to do |format|
      if params[:opac]
        if @manifestations.size > 0
          format.html { render :template => 'opac/manifestations/index', :layout => 'opac' }
        else
          flash[:notice] = t('page.no_record_found')
          format.html { render :template => 'opac/search', :layout => 'opac' }
        end
      end
      format.html
      format.mobile
      format.xml  { render :xml => @manifestations }
      format.sru  { render :layout => false }
      format.rss  { render :layout => false }
      format.csv  { render :layout => false }
      format.rdf  { render :layout => false }
      format.atom
      format.oai {
        if @manifestations.blank?
          @oai[:errors] << 'noRecordsMatch'
        else
          from_and_until_times = set_from_and_until(Manifestation, params[:from], params[:until])
          from_time = from_and_until_times[:from] || Manifestation.last.updated_at
          until_time = from_and_until_times[:until] || Manifestation.first.updated_at
          set_resumption_token(params[:resumptionToken], from_time, until_time)
        end

        case params[:verb]
        when 'Identify'
          render :template => 'manifestations/identify'
        when 'ListMetadataFormats'
          render :template => 'manifestations/list_metadata_formats'
        when 'ListSets'
          @series_statements = SeriesStatement.select([:id, :original_title])
          render :template => 'manifestations/list_sets'
        when 'ListIdentifiers'
          render :template => 'manifestations/list_identifiers'
        when 'ListRecords'
          render :template => 'manifestations/list_records'
        end
      }
      format.mods
      format.json { render :json => @manifestations }
      format.js { render 'binding_items/manifestations'}
    end
  #rescue QueryError => e
  #  render :template => 'manifestations/error.xml', :layout => false
  #  Rails.logger.info "#{Time.zone.now}\t#{query}\t\t#{current_user.try(:username)}\t#{e}"
  #  return
  end

  # GET /manifestations/1
  # GET /manifestations/1.json
  def show
    can_show = true
    unless user_signed_in?
      can_show = false if @manifestation.non_searchable?
    else
      can_show = false if !current_user.has_role?('Librarian') and @manifestation.non_searchable?
    end
    unless can_show
      access_denied; return
    end

    if params[:isbn].present?
      if @manifestation = Manifestation.find_by_isbn(params[:isbn])
        redirect_to @manifestation
        return
      else
        raise ActiveRecord::RecordNotFound if @manifestation.nil?
      end
    else
      if @version
        @manifestation = @manifestation.versions.find(@version).item if @version
      #else
      #  @manifestation = Manifestation.find(params[:id], :include => [:creators, :contributors, :publishers, :items])
      end
    end

    case params[:mode]
    when 'send_email'
      if user_signed_in?
        Notifier.delay.manifestation_info(current_user, @manifestation)
        flash[:notice] = t('page.sent_email')
        redirect_to @manifestation
        return
      else
        access_denied; return
      end
    end

    return if render_mode(params[:mode])

    if Setting.operation
      @reserved_count = Reserve.waiting.where(:manifestation_id => @manifestation.id, :checked_out_at => nil).count
      @reserve = current_user.reserves.where(:manifestation_id => @manifestation.id).last if user_signed_in?
    end

    if @manifestation.periodical_master?
      if params[:opac]
        redirect_to series_statement_manifestations_url(@manifestation.series_statement, :opac => true)
      elsif params[:all_manifestations]
        redirect_to series_statement_manifestations_url(@manifestation.series_statement, :all_manifestations => true)
      else
        redirect_to series_statement_manifestations_url(@manifestation.series_statement)
      end
      return
    end

    store_location

    if @manifestation.attachment.path
      if Setting.uploaded_file.storage == :s3
        data = open(@manifestation.attachment.url) {|io| io.read }.force_encoding('UTF-8')
      else
        file = @manifestation.attachment.path
      end
    end

    if @manifestation.bookbinder
      @binder = @manifestation.items.where(:bookbinder => true).first rescue nil
    end

    respond_to do |format|
      format.html { render :template => 'opac/manifestations/show', :layout => 'opac' } if params[:opac]
      format.html # show.html.erb
      format.mobile
      format.xml  {
        case params[:mode]
        when 'related'
          render :template => 'manifestations/related'
        else
          render :xml => @manifestation
        end
      }
      format.rdf
      format.oai
      format.mods
      format.json { render :json => @manifestation }
      #format.atom { render :template => 'manifestations/oai_ore' }
      #format.js
      format.download {
        if @manifestation.attachment.path
          if Setting.uploaded_file.storage == :s3
            send_data @manifestation.attachment.data, :filename => @manifestation.attachment_file_name.encode("cp932"), :type => 'application/octet-stream'
          else
            send_file file, :filename => @manifestation.attachment_file_name.encode("cp932"), :type => 'application/octet-stream'
          end
        else
          render :template => 'page/404', :status => 404
        end
      }
    end
  end

  # GET /manifestations/new
  # GET /manifestations/new.json
  def new
    @manifestation = Manifestation.new
    @manifestation.language = Language.where(:iso_639_1 => @locale).first
    original_manifestation = Manifestation.where(:id => params[:manifestation_id]).first
    if original_manifestation
      @manifestation = original_manifestation.dup
      @creator = original_manifestation.creators.collect(&:full_name).flatten.join(';')
      @creator_transcription = original_manifestation.creators.collect(&:full_name_transcription).flatten.join(';')
      @contributor = original_manifestation.contributors.collect(&:full_name).flatten.join(';')
      @contributor_transcription = original_manifestation.contributors.collect(&:full_name_transcription).flatten.join(';')
      @publisher = original_manifestation.publishers.collect(&:full_name).flatten.join(';')
      @publisher_transcription = original_manifestation.publishers.collect(&:full_name_transcription).flatten.join(';')
      @subject = original_manifestation.subjects.collect(&:term).join(';')
      @subject_transcription = original_manifestation.subjects.collect(&:term_transcription).join(';')
      @manifestation.isbn = nil if SystemConfiguration.get("manifestation.isbn_unique")
      @manifestation.series_statement = original_manifestation.series_statement unless @manifestation.series_statement
    elsif @expression
      @manifestation.original_title = @expression.original_title
      @manifestation.title_transcription = @expression.title_transcription
    elsif @series_statement
      @manifestation.original_title = @series_statement.original_title
      @manifestation.title_transcription = @series_statement.title_transcription
      @manifestation.issn = @series_statement.issn
      if @series_statement.root_manifestation
        root_manifestation = @series_statement.root_manifestation
        @creator = root_manifestation.creators.collect(&:full_name).flatten.join(';')
        @creator_transcription = root_manifestation.creators.collect(&:full_name_transcription).flatten.join(';')
        @contributor = root_manifestation.contributors.collect(&:full_name).flatten.join(';')
        @contributor_transcription = root_manifestation.contributors.collect(&:full_name_transcription).flatten.join(';')
        @publisher = root_manifestation.publishers.collect(&:full_name).flatten.join(';')
        @publisher_transcription = root_manifestation.publishers.collect(&:full_name_transcription).flatten.join(';')
        @manifestation.carrier_type = root_manifestation.carrier_type
        @manifestation.manifestation_type = root_manifestation.manifestation_type
        @manifestation.frequency = root_manifestation.frequency
        @manifestation.country_of_publication = root_manifestation.country_of_publication
        @manifestation.place_of_publication = root_manifestation.place_of_publication
        @manifestation.language = root_manifestation.language
        @manifestation.access_address = root_manifestation.access_address
        @manifestation.required_role = root_manifestation.required_role
      end
      @manifestation.series_statement = @series_statement
    end

    @manifestation = ManifestationsController.helpers.set_serial_number(@manifestation) if params[:mode] == 'new_issue'
    @original_manifestation = original_manifestation if params[:mode] == 'add'
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @manifestation }
    end
  end

  # GET /manifestations/1/edit
  def edit
    unless current_user.has_role?('Librarian')
      unless params[:mode] == 'tag_edit'
        access_denied; return
      end
    end
    @original_manifestation = Manifestation.where(:id => params[:manifestation_id]).first
    @manifestation.series_statement = @series_statement if @series_statement
    @creator = @manifestation.creators.collect(&:full_name).flatten.join(';')
    @creator_transcription = @manifestation.creators.collect(&:full_name_transcription).flatten.join(';')
    @contributor = @manifestation.contributors.collect(&:full_name).flatten.join(';')
    @contributor_transcription = @manifestation.contributors.collect(&:full_name_transcription).flatten.join(';')
    @publisher = @manifestation.publishers.collect(&:full_name).flatten.join(';')
    @publisher_transcription = @manifestation.publishers.collect(&:full_name_transcription).flatten.join(';')
    @subject = @manifestation.subjects.collect(&:term).join(';')
    @subject_transcription = @manifestation.subjects.collect(&:term_transcription).join(';')
    if defined?(EnjuBookmark)
      if params[:mode] == 'tag_edit'
        @bookmark = current_user.bookmarks.where(:manifestation_id => @manifestation.id).first if @manifestation rescue nil
        render :partial => 'manifestations/tag_edit', :locals => {:manifestation => @manifestation}
      end
      store_location unless params[:mode] == 'tag_edit'
    end
  end

  # POST /manifestations
  # POST /manifestations.json
  def create
    @manifestation = Manifestation.new(params[:manifestation])
    @original_manifestation = Manifestation.where(:id => params[:manifestation_id]).first
    if @manifestation.respond_to?(:post_to_scribd)
      @manifestation.post_to_scribd = true if params[:manifestation][:post_to_scribd] == "1"
    end
    unless @manifestation.original_title?
      @manifestation.original_title = @manifestation.attachment_file_name
    end
    if params[:manifestation][:series_statement_id]
      series_statement = SeriesStatement.find(params[:manifestation][:series_statement_id])
      @manifestation.series_statement = series_statement if  series_statement
    end
    @creator = params[:manifestation][:creator]
    @creator_transcription = params[:manifestation][:creator_transcription]
    @publisher = params[:manifestation][:publisher]
    @publisher_transcription = params[:manifestation][:publisher_transcription]
    @contributor = params[:manifestation][:contributor]
    @contributor_transcription = params[:manifestation][:contributor_transcription]
    @subject = params[:manifestation][:subject]
    @subject_transcription = params[:manifestation][:subject_transcription]

    respond_to do |format|
      if @manifestation.save
        Manifestation.transaction do
          if @original_manifestation
            @manifestation.derived_manifestations << @original_manifestation
          end
          if @manifestation.series_statement and @manifestation.series_statement.periodical
            Manifestation.find(@manifestation.series_statement.root_manifestation_id).index
          end
          @manifestation.creators = Patron.add_patrons(@creator, @creator_transcription) unless @creator.blank?
          @manifestation.contributors = Patron.add_patrons(@contributor, @contributor_transcription) unless @contributor.blank?
          @manifestation.publishers = Patron.add_patrons(@publisher, @publisher_transcription) unless @publisher.blank?
          @manifestation.subjects = Subject.import_subjects(@subject, @subject_transcription) unless @subject.blank?
        end

        format.html { redirect_to @manifestation, :notice => t('controller.successfully_created', :model => t('activerecord.models.manifestation')) }
        format.json { render :json => @manifestation, :status => :created, :location => @manifestation }
      else
        prepare_options
        format.html { render :action => "new"}
        format.json { render :json => @manifestation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /manifestations/1
  # PUT /manifestations/1.json
  def update
    @creator = params[:manifestation][:creator]
    @creator_transcription = params[:manifestation][:creator_transcription]
    @publisher = params[:manifestation][:publisher]
    @publisher_transcription = params[:manifestation][:publisher_transcription]
    @contributor = params[:manifestation][:contributor]
    @contributor_transcription = params[:manifestation][:contributor_transcription]
    @subject = params[:manifestation][:subject]
    @subject_transcription = params[:manifestation][:subject_transcription]
    respond_to do |format|
      if @manifestation.update_attributes(params[:manifestation])
        if @manifestation.series_statement and @manifestation.series_statement.periodical
          Manifestation.find(@manifestation.series_statement.root_manifestation_id).index
        end
        #TODO update position to edit patrons without destroy
        @manifestation.creators.destroy_all; @manifestation.creators = Patron.add_patrons(@creator, @creator_transcription) 
        @manifestation.contributors.destroy_all; @manifestation.contributors = Patron.add_patrons(@contributor, @contributor_transcription) 
        @manifestation.publishers.destroy_all; @manifestation.publishers = Patron.add_patrons(@publisher, @publisher_transcription)
        @manifestation.subjects = Subject.import_subjects(@subject, @subject_transcription) 
        format.html { redirect_to @manifestation, :notice => t('controller.successfully_updated', :model => t('activerecord.models.manifestation')) }
        format.json { head :no_content }
      else
        prepare_options
        format.html { render :action => "edit" }
        format.json { render :json => @manifestation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /manifestations/1
  # DELETE /manifestations/1.json
  def destroy
    @manifestation.destroy
    flash[:message] = t('controller.successfully_deleted', :model => t('activerecord.models.manifestation'))

    respond_to do |format|
      format.html { redirect_to manifestations_url }
      format.json { head :no_content }
    end
  end

  def output_show
    @manifestation = Manifestation.find(params[:id])
    data = Manifestation.get_manifestation_locate(@manifestation, current_user)
    send_data data.generate, :filename => Setting.manifestation_locate_print.filename
  end
  
  def output_pdf
    output_show
  end

  private

  # solrに送信するqパラメータ文字列を構成する
  # TODO: integerやstringもqfに含める
  # TODO: このメソッドをManifestationに移動する
  def make_query_string_and_hl_pattern
    qwords = []
    highlight = []

    #
    # basic search
    #
    query = fixup_query_string(params[:query])

    query = "#{query}*" if query.size == 1


    query = '' if query == '[* TO *]'
    if query.present?
      qws = each_query_word(query) do |qw|
        highlight << /#{highlight_pattern(qw)}/
      end

      if qws.size == 1
        qwords << qws
      elsif params[:query_merge] == 'all' || params[:query_merge] != 'any' && SystemConfiguration.get("search.use_and")
        qwords << qws.join(' AND ')
      else
        qwords << '(' + qws.join(' OR ') + ')'
      end
    end
    # recent manifestations
    qwords << "created_at_d:[NOW-1MONTH TO NOW] AND except_recent_b:false" if params[:mode] == 'recent'

    #
    # advanced search
    #

    # exact match
    exact_match = []
    if params[:title].present? && params[:title_merge] == 'exact'
      exact_match << :title
      t = params[:title]
      highlight << /\A#{highlight_pattern(t)}\z/
      qwords << %Q[title_sm:"#{t.gsub(/"/, '\\"')}"]
    end

    if params[:creator].present? && params[:creator_merge] == 'exact'
      exact_match << :creator
      t = params[:creator].gsub(/\s/, '') # インデックス登録時の値に合わせて空白を除去しておく
      highlight << /\A#{highlight_pattern(t)}\z/
      qwords << %Q[creator_sm:"#{t.gsub(/"/, '\\"')}"]
    end

    # other attributes
    [
      [:tag, 'tag_sm'],
      [:title, 'title_text'],
      [:creator, 'creator_text'],
      [:contributor, 'contributor_text'],
      [:isbn, 'isbn_sm'],
      [:issn, 'issn_sm'],
      [:lccn, 'lccn_s'],
      [:nbn, 'nbn_s'],
      [:publisher, 'publisher_text'],
      [:item_identifier, 'item_identifier_sm'],
      [:manifestation_type, 'manifestation_type_sm'],
      [:except_query, nil],
      [:except_title, 'title_text'],
      [:except_creator, 'creator_text'],
      [:except_publisher, 'publisher_text'],
    ].each do |key, field|
      next if exact_match.include?(key)

      value = params[key]
      next if value.blank?

      qws = []
      hls = []

      merge_type = params[:"#{key}_merge"]
      flg = /\Aexcept_/ =~ key.to_s ? '-' : ''
      tag = "#{field}:" if field
      each_query_word(value) do |word|
        hls << word if flg.blank?
        word = "*#{word}*" if word.size == 1
        qws << "#{flg}#{word}"
      end

      if qws.size > 1 && merge_type == 'any'
        qwords.push "#{tag}(#{qws.join(' OR ')})"
      else
        qwords.push "#{tag}(#{qws.join(' AND ')})"
      end

      if (key == :title || key == :creator) &&
          flg!= '-' && !hls.blank? && merge_type != 'exact'
        highlight.concat hls.map {|t| /#{highlight_pattern(t)}/ }
      end
    end

    # range
    [
      [:number_of_pages_at_least, :number_of_pages_at_most,
        :num_range_query, 'number_of_pages'],
      [:pub_date_from, :pub_date_to,
        :date_range_query, 'pub_date'],
      [:acquired_from, :acquired_to,
        :date_range_query, 'acquired_at'],
      [:removed_from, :removed_to,
        :date_range_query, 'removed_at'],
    ].each do |p1, p2, conv_method, field_base|
      next unless params[p1] || params[p2]
      q = __send__(conv_method, field_base, params[p1], params[p2])
      qwords << q if q
    end

    # 詳細検索からの資料区分 ファセット選択時は無効とする
    if params[:manifestation_types].present? && params[:manifestation_type].blank?
      types_ary = []
      manifestation_types = params[:manifestation_types]
      manifestation_types.each_key do |key|
        manifestation_type = ManifestationType.find(key)
        types_ary << manifestation_type.name if manifestation_type.present?
      end
      qwords << "manifestation_type_sm:(" + types_ary.join(" OR ") + ")" if types_ary.present?
    end

    # merge basic and advanced
    op = SystemConfiguration.get("advanced_search.use_and") ? 'AND' : 'OR'
    [qwords.join(" #{op} "), highlight]
  end

  def highlight_pattern(str)
    str = $2 if /\A(['"])(.*)\1\z/ =~ str
    str.split(/\s+/).map {|s| Regexp.quote(s) }.join('(?>\\s+)')
  end

  # solr searchのためのfilter指定を構成する
  # TODO: このメソッドをManifestationに移動する
  def make_query_filter(options)
    with = []
    without = []

    #
    # params['mode']に関係なく設定するフィルタ
    #

    with << [
      :required_role_id, :less_than_or_equal_to,
      (current_user.try(:role) || Role.default_role).id
    ]

    if @removed
      with << [:has_removed, :equal_to, true]
    elsif !params[:missing_issue] &&
        SystemConfiguration.get('manifestation.manage_item_rank') &&
        @all_manifestations.blank?
      without << [:non_searchable, :equal_to, true]
    end

    without << [:id, :equal_to, @binder.manifestation.id] if @binder

    unless options[:with_periodical_item]
      unless @binder
        with << [:periodical, :equal_to, false] if options[:add_mode] || @series_statement.blank?
      end
    end 

    return [with, without] if options[:add_mode]

    #
    # params['mode']が'add'でないときだけ設定するフィルタ
    #
    with << [:reservable, :equal_to, @reservable] unless @reservable.nil?
    with << [:periodical_master, :equal_to, false] if @series_statement
    with << [:carrier_type, :equal_to, params[:carrier_type]] if params[:carrier_type]
    with << [:missing_issue, :equal_to, params[:missing_issue]] if params[:missing_issue]
    with << [:in_process, :equal_to, @in_process] unless @in_process.nil?
    with << [:manifestation_type, :equal_to, params[:manifestation_type]] if params[:manifestation_type]
    with << [:circulation_status_in_process, :equal_to, params[:circulation_status_in_process]] if params[:circulation_status_in_process]
    with << [:circulation_status_in_factory, :equal_to, params[:circulation_status_in_factory]] if params[:circulation_status_in_factory]

    [
      [:publisher_ids, @patron],
      [:creator_ids, @index_patron[:creator]],
      [:contributor_ids, @index_patron[:contributor]],
      [:publisher_ids, @index_patron[:publisher]],
      [:original_manifestation_ids, @manifestation],
      [:subject_ids, @subject],
      [:bookbinder_id, @binder],
      [:series_statement_id, @series_statement],
    ].each do |field, record|
      with << [field, :equal_to, record.id] if record
    end

    if params[:subject]
      subject = Subject.where(term: params[:subject]).first
      with << [:subject, :equal_to, subject.try(:term)]
    end

    unless params[:library].blank?
      params[:library].split.uniq.each do |library|
        with << [:library, :equal_to, library]
      end
    end

    unless params[:language].blank?
      params[:language].split.uniq.each do |language|
        with << [:language, :equal_to, language]
      end
    end
    [with, without]
  end

  # Solr検索式を生成するための
  # 以下の前処理を加えた新しい文字列を返す
  #  * いわゆる全角空白文字をASCII空白文字("\x20")に変換する
  #  * 連続する空白文字を一つの空白文字に変換する
  #  * 文字列の先頭と末尾の空白文字を削除する
  def fixup_query_string(str)
    str.to_s.gsub(/[　\s]+/, ' ').strip
  end

  # 空白を含まない文字列、"..."、'...'を抽出する
  # ただし単独のAND、ORは"AND"、"OR"に変換して返す
  # ブロックが与えられていれば抽出した文字列に適用する
  def each_query_word(str)
    ary = []
    str = fixup_query_string(str)
    str.scan(/([^"'\s]\S*|(["'])(?:(?:\\\\)+|\\\2|.)*?\2)/) do
      word = $1
      word = "\"#{word}\"" if /\A(?:and|or)\z/io =~ word
      ary << word
      yield(word) if block_given?
    end
    ary
  end

  def search_result_order(sort_by, order)
    sort = {}
    # TODO: ページ数や大きさでの並べ替え
    case sort_by
    when 'title'
      sort[:sort_by] = 'sort_title'
      sort[:order] = 'asc'
    when 'pub_date'
      sort[:sort_by] = 'date_of_publication'
      sort[:order] = 'desc'
    when 'carrier_type'
      sort[:sort_by] = 'carrier_type'
      sort[:order] = 'desc'
    when 'author'
      sort[:sort_by] = 'author'
      sort[:order] = 'asc'
    else
      # デフォルトの並び方
      sort[:sort_by] = 'created_at'
      sort[:order] = 'desc'
    end
    if order == 'asc'
      sort[:order] = 'asc'
    elsif order == 'desc'
      sort[:order] = 'desc'
    end
    sort
  end

  def render_mode(mode)
    case mode
    when 'barcode'
      barcode = Barby::QrCode.new(@manifestation.id)
      send_data(barcode.to_svg, :disposition => 'inline', :type => 'image/svg+xml')
    when 'holding'
      render :partial => 'manifestations/show_holding', :locals => {:manifestation => @manifestation}
    when 'tag_edit'
      if defined?(EnjuBookmark)
        render :partial => 'manifestations/tag_edit', :locals => {:manifestation => @manifestation}
      end
    when 'tag_list'
      if defined?(EnjuBookmark)
        render :partial => 'manifestations/tag_list', :locals => {:manifestation => @manifestation}
      end
    when 'show_index'
      render :partial => 'manifestations/show_index', :locals => {:manifestation => @manifestation}
    when 'show_creators'
      render :partial => 'manifestations/show_creators', :locals => {:manifestation => @manifestation}
    when 'show_all_creators'
      render :partial => 'manifestations/show_creators', :locals => {:manifestation => @manifestation}
    when 'pickup'
      render :partial => 'manifestations/pickup', :locals => {:manifestation => @manifestation}
    when 'calil_list'
      render :partial => 'manifestations/calil_list', :locals => {:manifestation => @manifestation}
    else
      false
    end
  end

  def prepare_options
    @carrier_types = CarrierType.all
    @manifestation_types = ManifestationType.all
    @roles = Role.all
    @languages = Language.all_cache
    @countries = Country.all
    @frequencies = Frequency.all
    @nii_types = NiiType.all if defined?(NiiType)
  end

  def save_search_history(query, offset = 0, total = 0, user = nil)
    check_dsbl if LibraryGroup.site_config.use_dsbl
    if SystemConfiguration.get("write_search_log_to_file")
      write_search_log(query, total, user)
    else
      SearchHistory.create(:query => query, :user => user, :start_record => offset + 1, :maximum_records => nil, :number_of_records => total)
    end
  end

  def write_search_log(query, total, user)
    SEARCH_LOGGER.info "#{Time.zone.now}\t#{query}\t#{total}\t#{user.try(:username)}\t#{params[:format]}"
  end

  def get_index_patron
    patron = {}
    case
    when params[:patron_id]
      patron[:patron] = Patron.find(params[:patron_id])
    when params[:creator_id]
      patron[:creator] = Patron.find(params[:creator_id])
    when params[:contributor_id]
      patron[:contributor] = Patron.find(params[:contributor_id])
    when params[:publisher_id]
      patron[:publisher] = Patron.find(params[:publisher_id])
    end
    patron
  end

  def set_reservable
    case params[:reservable].to_s
    when 'true'
      @reservable = true
    when 'false'
      @reservable = false
    else
      @reservable = nil
    end
  end

  def set_in_process
    case params[:in_process].to_s
    when 'true'
      @in_process = true
    when 'false'
      @in_process = false
    else
      @in_process = nil
    end
  end

  # "*_sm"フィールドに対する自然数の範囲条件を指定する
  # solrクエリー文字列を返す
  def num_range_query(field_base, num_from, num_to)
    n1 = n2 = nil
    num_regex = /\A0*[1-9]\d*/

    n1 = $&.to_i if num_regex =~ num_from
    n2 = $&.to_i if num_regex =~ num_to

    n1, n2 = n2, n1 if n1 && n2 && n1 > n2

    block = proc {|n| n < 1 }
    r_begin = (n1.nil? || block.call(n1)) ? '*' : n1.to_s
    r_end   = (n2.nil? || block.call(n2)) ? '*' : n2.to_s

    return nil if r_begin == '*' && r_end == '*'
    "#{field_base}_sm:[#{r_begin} TO #{r_end}]"
  end

  # "*_sm"フィールドに対する日時範囲条件を指定する
  # solrクエリー文字列を返す。
  def date_range_query(field_base, date_from, date_to)
    d1, g1 = parse_date(date_from)
    d2, g2 = parse_date(date_to)

    d1, g1, d2, g2 = d2, g2, d1, g1 if d1 && d2 && d1 > d2

    if d1
      r_begin = d1.beginning_of_day.utc.iso8601
    else
      r_begin = '*'
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
      r_end = d2.utc.iso8601 if d2
    else
      r_end = '*'
    end

    return nil if r_begin == '*' && r_end == '*'
    "#{field_base}_sm:[#{r_begin} TO #{r_end}]"
  end

  # 日時を示す文字列を解析して
  # 解析できた時刻とそのレベル(:day、:month、:year)を返す
  def parse_date(date_str)
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

  def next_page_number_for_oai_search
    return 1 unless params[:resumptionToken]

    current_token = get_resumption_token(params[:resumptionToken])
    unless current_token
      @oai[:errors] << 'badResumptionToken'
      return 1
    end

    per_page = 200 # OAI-PMHのデフォルトの件数
    (current_token[:cursor].to_i + per_page).div(per_page) + 1
  end

  def total_search_result_count(result)
    max_count = SystemConfiguration.get("max_number_of_results")
    total = result.total
    total > max_count ? max_count : total
  end
end
