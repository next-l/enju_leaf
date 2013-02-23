# -*- encoding: utf-8 -*-
class ManifestationsController < ApplicationController
  add_breadcrumb "I18n.t('breadcrumb.search_manifestations')", 'manifestations_path', :only => [:index], :unless => proc{params}
  add_breadcrumb "I18n.t('breadcrumb.search_manifestations')", 'manifestations_path(params)', :only => [:index], :if => proc{params}
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
    if params[:mode] == 'add'
      unless current_user.has_role?('Librarian')
        access_denied; return 
      end
      @add = true
    end

    per_page = per_pages[0] if per_pages
    @seconds = Benchmark.realtime do
      @oai = check_oai_params(params)
      next if @oai[:need_not_to_search]
      if params[:format] == 'oai'
        from_and_until_times = set_from_and_until(Manifestation, params[:from], params[:until])
        from_time = @from_time = from_and_until_times[:from]
        until_time = @until_time = from_and_until_times[:until]
        # OAI-PMHのデフォルトの件数
        per_page = 200
        if params[:resumptionToken]
          if current_token = get_resumption_token(params[:resumptionToken])
            page = (current_token[:cursor].to_i + per_page).div(per_page) + 1
          else
            @oai[:errors] << 'badResumptionToken'
          end
        else
        end
        page ||= 1

        if params[:verb] == 'GetRecord' and params[:identifier]
          begin
            @manifestation = Manifestation.find_by_oai_identifier(params[:identifier])
          rescue ActiveRecord::RecordNotFound
            @oai[:errors] << "idDoesNotExist"
            render :template => 'manifestations/index', :formats => :oai, :layout => false
            return
          end
          render :template => 'manifestations/show', :formats => :oai, :layout => false
          return
        end
      end

      set_reservable

      manifestations, sort, @count = {}, {}, {}
      query = ""

      per_page = 65534 if params[:format] == 'csv'

      if params[:format] == 'sru'
        if params[:operation] == 'searchRetrieve'
          sru = Sru.new(params)
          query = sru.cql.to_sunspot
          sort = sru.sort_by
        else
          render :template => 'manifestations/explain', :layout => false
          return
        end
      else
        if params[:api] == 'openurl'
          openurl = Openurl.new(params)
          @manifestations = openurl.search
          query = openurl.query_text
          sort = set_search_result_order(params[:sort_by], params[:order])
        else
          query = make_query(params[:query], params)
          sort = set_search_result_order(params[:sort_by], params[:order])
        end
      end

      # 絞り込みを行わない状態のクエリ
      @query = query.dup
      query = query.gsub('　', ' ')

      includes = [:carrier_type, :required_role, :items, :creators, :contributors, :publishers]
      includes << :bookmarks if defined?(EnjuBookmark)
      search = Sunspot.new_search(Manifestation)
      search_all = Sunspot.new_search(Manifestation)
      search_book = Sunspot.new_search(Manifestation)
      search_article = Sunspot.new_search(Manifestation)
      role = current_user.try(:role) || Role.default_role
      oai_search = true if params[:format] == 'oai'
      case @reservable
      when 'true'
        reservable = true
      when 'false'
        reservable = false
      else
        reservable = nil
      end

      get_manifestation; get_subject
      patron = get_index_patron
      @index_patron = patron

      split_by_type = SystemConfiguration.get("manifestations.split_by_type")
      with_article = SystemConfiguration.get('internal_server') || clinet_is_special_ip?

      searchs = [ search_all ]
      if split_by_type
        searchs << search_book
        searchs << search_article if with_article
      end

      searchs.each do |s|
      search = s

      @binder = binder = Manifestation.find(params[:bookbinder_id]).try(:items).try(:first) if params[:bookbinder_id]
      unless params[:mode] == 'add'
        manifestation = @manifestation if @manifestation
        subject = @subject if @subject
        series_statement = @series_statement if @series_statement
        search.build do
          with(:creator_ids).equal_to patron[:creator].id if patron[:creator]
          with(:contributor_ids).equal_to patron[:contributor].id if patron[:contributor]
          with(:publisher_ids).equal_to patron[:publisher].id if patron[:publisher]
          with(:original_manifestation_ids).equal_to manifestation.id if manifestation
        end
        search.data_accessor_for(Manifestation).include = includes
      end

      removed = @removed = true if params[:removed_from].present? or params[:removed_to].present? or params[:removed]
      missing_issue = true if params[:missing_issue]
      search.build do
        fulltext query unless query.blank?
        order_by sort[:sort_by], sort[:order] unless oai_search
        order_by :created_at, :desc unless oai_search
        order_by :updated_at, :desc if oai_search
        with(:subject_ids).equal_to subject.id if subject
        unless removed
          unless missing_issue
            if SystemConfiguration.get('manifestation.manage_item_rank')
              without(:non_searchable).equal_to true unless params[:all_manifestations]
            end
          end
        else
          with(:has_removed).equal_to true
        end
        if series_statement
          with(:series_statement_id).equal_to series_statement.id
          #if series_statement.periodical?
            #with(:periodical).equal_to true
            with(:periodical_master).equal_to false
          #else
          #  with(:periodical).equal_to false
          #end
        else
          with(:periodical).equal_to false
        end
#TODO search missing issue
#        if missing_issue
#          with(:missing_issue)
#        end
        facet :reservable
        with(:in_process).equal_to params[:in_ptocess] == 'true' ? true : false if params[:in_process]  #TODO:
        with(:bookbinder_id).equal_to binder.id if params[:mode] != 'add' && binder
        without(:id, binder.manifestation.id) if binder
        if s.equal?(search_book)
          with(:is_article).equal_to false
        elsif s.equal?(search_article)
          without(:is_article).equal_to false
        end
      end
      search = make_internal_query(search)
      search.data_accessor_for(Manifestation).select = [
        :id,
        :original_title,
        :title_transcription,
        :required_role_id,
        :manifestation_type_id,
        :carrier_type_id,
        :access_address,
        :volume_number_string,
        :issue_number_string,
        :serial_number_string,
        :date_of_publication,
        :pub_date,
        :periodical_master,
        :language_id,
        :carrier_type_id,
        :created_at,
        :note,
        :missing_issue
      ] if (params[:format] == 'html' or params[:format].nil?) && params[:missing_issue].nil?
      end

      search = search_all

      # catch query error 
      begin
        all_result = search.execute
        @count[:query_result] = all_result.total
        @reservable_facet = all_result.facet(:reservable).rows
      rescue Exception => e
        flash[:message] = t('manifestation.invalid_query')
        logger.error "query error: #{e}"
        return
      end	

      if session[:search_params]
        unless search.query.to_params == session[:search_params]
          clear_search_sessions
        end
      else
        clear_search_sessions
        session[:params] = params
        session[:search_params] == search.query.to_params
        session[:query] = @query
      end

      # output
      if params[:output_pdf] or params[:output_tsv] or params[:output_excelx] or params[:output_request]
        output_type =
          case
          when params[:output_pdf]; :pdf
          when params[:output_tsv]; :tsv
          when params[:output_excelx]; :excelx
          when params[:output_request]; :request
          end
        Manifestation.generate_manifestation_list(search, output_type, current_user, params[:cols]) do |output|
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
      unless session[:manifestation_ids]
        manifestation_ids = search.build do
          paginate :page => 1, :per_page => SystemConfiguration.get("max_number_of_results")
        end.execute.raw_results.collect(&:primary_key).map{|id| id.to_i}
        session[:manifestation_ids] = manifestation_ids
      end

      if session[:manifestation_ids]
        if defined?(EnjuBookmark)
          if params[:view] == 'tag_cloud'
            bookmark_ids = Bookmark.where(:manifestation_id => session[:manifestation_ids]).limit(1000).select(:id).collect(&:id)
            @tags = Tag.bookmarked(bookmark_ids)
            render :partial => 'manifestations/tag_cloud'
            #session[:manifestation_ids] = nil
            return
          end
        end
      end
      page ||= params[:page] || 1
      page_article ||= params[:page_article] || 1
      per_page = cookies[:per_page] if cookies[:per_page]
      per_page = params[:per_page] if params[:per_page]#Manifestation.per_page
      @per_page = per_page
      cookies.permanent[:per_page] = { :value => per_page }
      if params[:format] == 'sru'
        search.query.start_record(params[:startRecord] || 1, params[:maximumRecords] || 200)
      else
        searchs.each do |s|
        search = s
        search.build do
          facet :reservable
          facet :carrier_type
          facet :library
          facet :language
          facet :subject_ids
          facet :manifestation_type
          facet :missing_issue
          facet :in_process
          if s == search_article
            paginate :page => page_article.to_i, :per_page => per_page unless request.xhr?
          else
            paginate :page => page.to_i, :per_page => per_page unless request.xhr?
          end
          if params[:format].blank? or params[:format] == 'html'
            spellcheck :collate => 3, :q => params[:query]
          end
          end
        end
        search = search_all
      end
      # catch query error 
      begin
        search_result = search_all.execute
        if split_by_type
          search_book_result = search_book.execute
          search_article_result = search_article.execute if with_article
        end
      rescue Exception => e
        flash[:message] = t('manifestation.invalid_query')
        logger.error "query error: #{e}"
        return
      end
      if @count[:query_result] > SystemConfiguration.get("max_number_of_results")
        max_count = SystemConfiguration.get("max_number_of_results")
        if split_by_type
          max_book_count = max_count
          max_article_count = max_count
        end
      else
        max_count = @count[:query_result]
        if split_by_type
          max_book_count = search_book_result.total
          max_article_count = search_article_result.total if with_article
          max_article_count = search_article_result.total if with_article
        end
      end
      @manifestations = Kaminari.paginate_array(
        search_result.results, :total_count => max_count
      ).page(page).per(per_page)
      @manifestations_all = [ @manifestations ]
      if split_by_type
        @manifestations_book = Kaminari.paginate_array(
          search_book_result.results, :total_count => max_book_count
        ).page(page).per(per_page)
        @manifestations_all = [@manifestations_book]
        if with_article
          @manifestations_article = Kaminari.paginate_array(
            search_article_result.results, :total_count => max_article_count
          ).page(page_article).per(per_page)
          @manifestations_all << @manifestations_article
        end
	@split_by_type = split_by_type
      end
      @libraries = Library.real.all

      if params[:format].blank? or params[:format] == 'html'
        @carrier_type_facet = search_result.facet(:carrier_type).rows
        @language_facet = search_result.facet(:language).rows
        @library_facet = search_result.facet(:library).rows
        @manifestation_type_facet = search_result.facet(:manifestation_type).rows
        @missing_issue_facet = search_result.facet(:missing_issue).rows
        @in_process_facet = search_result.facet(:in_process).rows
      end

      @search_engines = Rails.cache.fetch('search_engine_all'){SearchEngine.all}

      # TODO: 検索結果が少ない場合にも表示させる
      if manifestation_ids.blank?
        if defined?(EnjuBookmark)
          if query.respond_to?(:suggest_tags)
            @suggested_tag = query.suggest_tags.first
          end
        end
        @collation = search_result.collation
      end

      save_search_history(query, @manifestations.limit_value, @count[:query_result], current_user)

      if params[:format] == 'oai'
        unless @manifestations.empty?
          set_resumption_token(params[:resumptionToken], @from_time || Manifestation.last.updated_at, @until_time || Manifestation.first.updated_at)
        else
          @oai[:errors] << 'noRecordsMatch'
        end
      end
    end
    store_location # before_filter ではファセット検索のURLを記憶してしまう

    @all_manifestations = params[:all_manifestations] if params[:all_manifestations]

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
    if params[:isbn]
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
      else
        redirect_to series_statement_manifestations_url(@manifestation.series_statement)
      end
      return
    end

    store_location

    if @manifestation.attachment.path
      if Setting.uploaded_file.storage == :s3
        data = open(@manifestation.attachment.url).read.force_encoding('UTF-8')
      else
        file = @manifestation.attachment.path
      end
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
            send_data @manifestation.attachment.data, :filename => @manifestation.attachment_file_name, :type => 'application/octet-stream'
          else
            send_file file, :filename => @manifestation.attachment_file_name, :type => 'application/octet-stream'
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
    original_manifestation = Manifestation.where(:id => params[:manifestation_id]).first
    if original_manifestation
      @manifestation = original_manifestation.dup
      @creator = original_manifestation.creators.collect(&:full_name).flatten.join(';')
      @contributor = original_manifestation.contributors.collect(&:full_name).flatten.join(';')
      @publisher = original_manifestation.publishers.collect(&:full_name).flatten.join(';')
      @subject = original_manifestation.subjects.collect(&:term).join(';')
      @manifestation.isbn = nil
      @manifestation.series_statement = original_manifestation.series_statement unless @manifestation.series_statement
    elsif @expression
      @manifestation.original_title = @expression.original_title
      @manifestation.title_transcription = @expression.title_transcription
    elsif @series_statement
      @manifestation.series_statement = @series_statement
    end
    @manifestation.language = Language.where(:iso_639_1 => @locale).first
    @manifestation = @manifestation.set_serial_number if params[:mode] == 'new_issue'
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
    @contributor = @manifestation.contributors.collect(&:full_name).flatten.join(';')
    @publisher = @manifestation.publishers.collect(&:full_name).flatten.join(';')
    @subject = @manifestation.subjects.collect(&:term).join(';')
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
    if params[:series_statement_id]
      series_statement = SeriesStatement.find(params[:series_statement_id])
      @manifestation.series_statement = series_statement id series_statement
    end
    @creator = params[:manifestation][:creator]
    @publisher = params[:manifestation][:publisher]
    @contributor = params[:manifestation][:contributor]
    @subject = params[:manifestation][:subject]

    respond_to do |format|
      if @manifestation.save
        Manifestation.transaction do
          if @original_manifestation
            @manifestation.derived_manifestations << @original_manifestation
          end
          if @manifestation.series_statement and @manifestation.series_statement.periodical
            Manifestation.find(@manifestation.series_statement.root_manifestation_id).index
          end
          @manifestation.creators = Patron.add_patrons(@creator) unless @creator.blank?
          @manifestation.contributors = Patron.add_patrons(@contributor) unless @contributor.blank?
          @manifestation.publishers = Patron.add_patrons(@publisher) unless @publisher.blank?
          @manifestation.subjects = Subject.import_subjects(@subject.gsub('；', ';').split(';')) unless @subject.blank?
          @manifestation.save
        end

        format.html { redirect_to @manifestation, :notice => t('controller.successfully_created', :model => t('activerecord.models.manifestation')) }
        format.json { render :json => @manifestation, :status => :created, :location => @manifestation }
      else
        prepare_options
        format.html { render :action => "new" }
        format.json { render :json => @manifestation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /manifestations/1
  # PUT /manifestations/1.json
  def update
    @creator = params[:manifestation][:creator]
    @publisher = params[:manifestation][:publisher]
    @contributor = params[:manifestation][:contributor]
    @subject = params[:manifestation][:subject]
    @manifestation.creators = Patron.add_patrons(@creator) unless @creator.blank?
    @manifestation.contributors = Patron.add_patrons(@contributor) unless @contributor.blank?
    @manifestation.publishers = Patron.add_patrons(@publisher) unless @publisher.blank?
    @manifestation.subjects = Subject.import_subjects(@subject.gsub('；', ';').split(';')) unless @subject.blank?
    respond_to do |format|
      if @manifestation.update_attributes(params[:manifestation])
        if @manifestation.series_statement and @manifestation.series_statement.periodical
          Manifestation.find(@manifestation.series_statement.root_manifestation_id).index
        end
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
  def make_query(query, options = {})
    # TODO: integerやstringもqfに含める
    # query
    query = query.to_s.strip
    if query.size == 1
      query = "#{query}*"
    end
    query = query.strip
    if query == '[* TO *]'
      #  unless params[:advanced_search]
      query = ''
      #  end
    end

    query = query.gsub(/[ 　\s]+/," ")
    query_words = query.split(' ')
    fix_query = ""
    query_words.each_with_index do |q, i|
      unless i == 0
        unless q =~ /^AND$|^OR$|^NOT$|^TO$|^\(|\)$|^\[|\]$/ or query_words[i - 1] =~ /^AND$|^OR$|^NOT$|^\(|\)$|^TO$|^\[|\]$/ 
          if SystemConfiguration.get("search.use_and")
            fix_query = "#{fix_query} AND "
          else
            fix_query = "#{fix_query} OR "
          end
        end
      end
      fix_query = fix_query + "#{q} "
    end
    query = fix_query

    # advanced_search
    queries = []
    #unless options[:carrier_type].blank?
    #  queries << "carrier_type_s:#{options[:carrier_type]}"
    #end
    #unless options[:library].blank?
    #  library_list = options[:library].split.uniq.join(' and ')
    #  queries << "library_sm:#{library_list}"
    #end
    #unless options[:language].blank?
    #  queries << "language_sm:#{options[:language]}"
    #end
    #unless options[:subject].blank?
    #  queries << "subject_sm:#{options[:subject]}"
    #end
    unless options[:tag].blank?
      queries << "tag_sm:#{options[:tag]}"
    end
    unless options[:creator].blank?
      queries << "creator_text:#{options[:creator]}"
    end
    unless options[:contributor].blank?
      queries << "contributor_text:#{options[:contributor]}"
    end
    unless options[:isbn].blank?
      queries << "isbn_sm:#{options[:isbn]}"
    end
    unless options[:issn].blank?
      queries << "issn_sm:#{options[:issn]}"
    end
    unless options[:lccn].blank?
      queries << "lccn_s:#{options[:lccn]}"
    end
    unless options[:nbn].blank?
      queries << "nbn_s:#{options[:nbn]}"
    end
    unless options[:publisher].blank?
      queries << "publisher_text:#{options[:publisher]}"
    end
    unless options[:item_identifier].blank?
      queries << "item_identifier_sm:#{options[:item_identifier]}"
    end
    unless options[:number_of_pages_at_least].blank? and options[:number_of_pages_at_most].blank?
      number_of_pages = {}
      number_of_pages[:at_least] = options[:number_of_pages_at_least].to_i
      number_of_pages[:at_most] = options[:number_of_pages_at_most].to_i
      number_of_pages[:at_least] = "*" if number_of_pages[:at_least] == 0
      number_of_pages[:at_most] = "*" if number_of_pages[:at_most] == 0
      queries << "number_of_pages_sm:[#{number_of_pages[:at_least]} TO #{number_of_pages[:at_most]}]"
    end
    unless options[:pub_date_from].blank? and options[:pub_date_to].blank?
      queries << set_date('pub_date', options[:pub_date_from], options[:pub_date_to])
    end
    unless options[:acquired_from].blank? and options[:acquired_to].blank?
      queries << set_date('acquired_at', options[:acquired_from], options[:acquired_to])
    end
    unless options[:removed_from].blank? and options[:removed_to].blank?
      queries << set_date('removed_at', options[:removed_from], options[:removed_to])
    end
    unless options[:manifestation_type].blank?
      queries << "manifestation_type_sm:#{options[:manifestation_type]}"
    end
    
    if SystemConfiguration.get("advanced_search.use_and")

      advanced_query = queries.join(' AND ')
      query = query + " AND " unless query
      query = query + advanced_query unless advanced_query.blank?
    else
      advanced_query = queries.join(' OR ')
      query = query + " OR " unless query
      query = query + advanced_query unless advanced_query.blank?
    end

    return query
  end

  def set_search_result_order(sort_by, order)
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
      history = SearchHistory.create(:query => query, :user => user, :start_record => offset + 1, :maximum_records => nil, :number_of_records => total)
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

  def set_date(column, date_from, date_to)
    date_from.to_s.gsub!(/\D/, '')
    date_to.to_s.gsub!(/\D/, '')
    date = {}
    if date_from.blank?
      date[:from] = "*"
    else
      date[:from] = Time.zone.parse(date_from).beginning_of_day.utc.iso8601 rescue nil
      date[:from] = Time.zone.parse(Time.mktime(date_from).to_s).beginning_of_day.utc.iso8601 unless date[:from]
    end
    if date_to.blank?
      date[:to] = "*"
    else
      date[:to] = Time.zone.parse(date_to).end_of_day.utc.iso8601 rescue nil
      date[:to] = Time.zone.parse(Time.mktime(date_to).to_s).beginning_of_day.utc.iso8601 unless date[:to] 
    end
    return "#{column}_sm:[#{date[:from]} TO #{date[:to]}]"
  end
end
