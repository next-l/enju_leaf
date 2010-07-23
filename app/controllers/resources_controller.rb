# -*- encoding: utf-8 -*-
class ResourcesController < ApplicationController
  load_and_authorize_resource
  before_filter :authenticate_user!, :only => :edit
  before_filter :get_patron
  before_filter :get_resource, :only => :index
  before_filter :get_manifestation, :only => :index
  before_filter :get_series_statement, :only => [:index, :new, :edit]
  before_filter :prepare_options, :only => [:new, :edit]
  before_filter :get_libraries, :only => :index
  before_filter :get_version, :only => [:show]
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  after_filter :convert_charset, :only => :index
  cache_sweeper :resource_sweeper, :only => [:create, :update, :destroy]
  #include WorldcatController
  include OaiController

  # GET /resources
  # GET /resources.xml
  def index
    @seconds = Benchmark.realtime do
      if params[:mode] == 'add'
        unless current_user.try(:has_role?, 'Librarian')
          access_denied; return
        end
      end
      @oai = check_oai_params(params)
      next if @oai[:need_not_to_search]
	    if user_signed_in?
	      @user = current_user unless @user
	    end

      if params[:format] == 'oai'
        from_and_until_times = set_from_and_until(Resource, params[:from], params[:until])
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
            @resource = Resource.find_by_oai_identifier(params[:identifier])
          rescue ActiveRecord::RecordNotFound
            @oai[:errors] << "idDoesNotExist"
            render :template => 'resources/index.oai.builder'
            return
          end
          render :template => 'resources/show.oai.builder'
          return
        end
      end

      case params[:reservable]
      when 'true'
        @reservable = 'true'
      when 'false'
        @reservable = 'false'
      else
        @reservable = nil
      end

      if params[:format] == 'csv'
        per_page = 65534
      end

      resources = {}
      @count = {}
      query = ""
      sort = {}

			case
      when params[:format] == 'sru'
        if params[:operation] == 'searchRetrieve'
          @sru = Sru.new(params)
          query = @sru.cql.to_sunspot
          sort = @sru.sort_by
        else
          render :template => 'resources/explain', :layout => false
          return
        end
      when params[:api] == 'openurl' 
        @openurl = Openurl.new(params)
        @resources = @openurl.search
        query = @openurl.query_text
        sort = set_search_result_order(params[:sort_by], params[:order])
      else
        query = make_query(params[:query], params)
        sort = set_search_result_order(params[:sort_by], params[:order])
      end

      # 絞り込みを行わない状態のクエリ
      @query = query.dup
      query = query.gsub('　', ' ')

      search = Sunspot.new_search(Resource)
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
      unless params[:mode] == 'add'
        resource = @resource if @resource
      end
      patron = get_index_patron
      search.build do
        fulltext query unless query.blank?
        with(:original_resource_ids).equal_to resource.id if resource
        order_by sort[:sort_by], sort[:order] unless oai_search
        order_by :updated_at, :desc if oai_search
        with(:creator_ids).equal_to patron[:creator].id if patron[:creator]
        with(:contributor_ids).equal_to patron[:contributor].id if patron[:contributor]
        with(:publisher_ids).equal_to patron[:publisher].id if patron[:publisher]
        facet :reservable
      end
      search = make_internal_query(search)
      all_result = search.execute!
      @count[:query_result] = all_result.total
      @reservable_facet = all_result.facet(:reservable).rows

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

      unless session[:resource_ids]
        resource_ids = search.build do
          paginate :page => 1, :per_page => configatron.max_number_of_results
        end.execute!.raw_results.collect(&:primary_key).map{|id| id.to_i}
        session[:resource_ids] = resource_ids
      end
        
      if session[:resource_ids]
        bookmark_ids = Bookmark.all(:select => :id, :conditions => {:manifestation_id => session[:resource_ids]}).collect(&:id)
        @tags = Tag.bookmarked(bookmark_ids)
        if params[:view] == 'tag_cloud'
          render :partial => 'manifestations/tag_cloud'
          #session[:resource_ids] = nil
          return
        end
      end

      page ||= params[:page] || 1
      if params[:format] == 'sru'
        search.query.start_record(params[:startRecord] || 1, params[:maximumRecords] || 200)
      else
        search.build do
          facet :reservable
          facet :carrier_type
          facet :library
          facet :language
          facet :subject_ids
          paginate :page => page.to_i, :per_page => per_page || Resource.per_page
        end
      end
      search_result = search.execute!
      @resources = search_result.results
      @resources.total_entries = configatron.max_number_of_results if @count[:query_result] > configatron.max_number_of_results

      if params[:format].blank? or params[:format] == 'html'
        @carrier_type_facet = search_result.facet(:carrier_type).rows
        @language_facet = search_result.facet(:language).rows
        @library_facet = search_result.facet(:library).rows
      end

      @search_engines = SearchEngine.all

      # TODO: 検索結果が少ない場合にも表示させる
      if resource_ids.blank?
        if query.respond_to?(:suggest_tags)
          @suggested_tag = query.suggest_tags.first
        end
      end
      save_search_history(query, @resources.offset, @count[:query_result], current_user)
      if params[:format] == 'oai'
        unless @resources.empty?
          set_resumption_token(@resources, @from_time || Resource.last.updated_at, @until_time || Resource.first.updated_at)
        else
          @oai[:errors] << 'noRecordsMatch'
        end
      end
    end

    store_location # before_filter ではファセット検索のURLを記憶してしまう

    respond_to do |format|
      format.html
      format.xml  { render :xml => @resources }
      format.sru  { render :layout => false }
      format.rss  { render :layout => false }
      format.csv  { render :layout => false }
      format.rdf  { render :layout => false }
      format.atom
      format.oai {
        case params[:verb]
        when 'Identify'
          render :template => 'resources/identify'
        when 'ListMetadataFormats'
          render :template => 'resources/list_metadata_formats'
        when 'ListSets'
          @series_statements = SeriesStatement.all
          render :template => 'resources/list_sets'
        when 'ListIdentifiers'
          render :template => 'resources/list_identifiers'
        when 'ListRecords'
          render :template => 'resources/list_records'
        end
      }
      format.mods
      format.json { render :json => @resources }
      format.js
      format.pdf {
        prawnto :prawn => {
          :page_layout => :landscape,
          :page_size => "A4"},
          :inline => true
      }
    end
  #rescue RSolr::RequestError
  #  unless params[:format] == 'sru'
  #    flash[:notice] = t('page.error_occured')
  #    redirect_to resources_url
  #    return
  #  else
  #    render :template => 'resources/error.xml', :layout => false
  #    return
  #  end
  #  return
  rescue QueryError => e
  #  render :template => 'resources/error.xml', :layout => false
    Rails.logger.info "#{Time.zone.now}\t#{query}\t\t#{current_user.try(:username)}\t#{e}"
  #  return
  end

  # GET /resources/1
  # GET /resources/1.xml
  def show
    if params[:api] or params[:mode] == 'generate_cache'
      unless my_networks?
        access_denied; return
      end
    end
    if params[:isbn]
      if @resource = Resource.find_by_isbn(params[:isbn])
        redirect_to @resource
        return
      else
        raise ActiveRecord::RecordNotFound if @resource.nil?
      end
    else
      @resource = Resource.find(params[:id], :include => :creators)
    end
    @resource = @resource.versions.find(@version).item if @version

    case params[:mode]
    when 'send_email'
      if user_signed_in?
        Notifier.resource_info(current_user, @resource).deliver
        flash[:notice] = t('page.sent_email')
        redirect_to resource_url(@resource)
        return
      end
    when 'generate_cache'
      check_client_ip_address
      return
    end

    return if render_mode(params[:mode])

    @reserved_count = Reserve.waiting.count(:all, :conditions => {:manifestation_id => @resource.id, :checked_out_at => nil})
    @reserve = current_user.reserves.first(:conditions => {:manifestation_id => @resource.id}) if user_signed_in?

    store_location

    respond_to do |format|
      format.html # show.rhtml
      format.xml  {
        case params[:mode]
        when 'related'
          render :template => 'resources/related'
        else
          render :xml => @resource
        end
      }
      format.rdf
      format.oai
      format.mods
      format.json { render :json => @resource }
      #format.atom { render :template => 'resources/oai_ore' }
      #format.xml  { render :action => 'mods', :layout => false }
      format.js
      format.pdf {
        prawnto :prawn => {
          :page_layout => :portrait,
          :page_size => "A4"},
          :inline => true
      }
    end
  end

  # GET /resources/new
  def new
    @resource = Resource.new
    @original_manifestation = get_manifestation
    @resource.series_statement = @series_statement
    unless params[:mode] == 'import_isbn'
      if @resource.series_statement
        @resource.original_title = @resource.series_statement.original_title
        @resource.title_transcription = @resource.series_statement.title_transcription
      elsif @original_manifestation
        @resource.original_title = @original_manifestation.original_title
        @resource.title_transcription = @original_manifestation.title_transcription
      elsif @expression
        @resource.original_title = @expression.original_title
        @resource.title_transcription = @expression.title_transcription
      end
    end
    @resource.language = Language.first(:conditions => {:iso_639_1 => @locale})
    @resource = @resource.set_serial_number unless params[:mode] == 'attachment'

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @resource }
    end
  end

  # GET /resources/1;edit
  def edit
    unless current_user.has_role?('Librarian')
      unless params[:mode] == 'tag_edit'
        access_denied; return
      end
    end
    @resource = Resource.find(params[:id])
    @original_manifestation = get_manifestation
    @resource.series_statement = @series_statement if @series_statement
    if params[:mode] == 'tag_edit'
      @bookmark = current_user.bookmarks.first(:conditions => {:manifestation_id => @resource.id}) if @resource rescue nil
      render :partial => 'manifestations/tag_edit', :locals => {:manifestation => @resource}
    end
    store_location unless params[:mode] == 'tag_edit'
  end

  # POST /resources
  # POST /resources.xml
  def create
    @resource = Resource.new(params[:resource])
    if @resource.respond_to?(:post_to_scribd)
      @resource.post_to_scribd = true if params[:resource][:post_to_scribd] == "1"
    end
    if @resource.original_title.blank?
      @resource.original_title = @resource.attachment_file_name
    end

    respond_to do |format|
      if @resource.save
        Resource.transaction do
          if @original_manifestation = get_resource
            @resource.derived_resources << @original_manifestation
          end
        end

        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.resource'))
        format.html { redirect_to(@resource) }
        format.xml  { render :xml => @resource, :status => :created, :location => @resource }
      else
        prepare_options
        format.html { render :action => "new" }
        format.xml  { render :xml => @resource.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /resources/1
  # PUT /resources/1.xml
  def update
    @resource = Resource.find(params[:id])
    
    respond_to do |format|
      if @resource.update_attributes(params[:resource])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.resource'))
        format.html { redirect_to @resource }
        format.xml  { head :ok }
        format.json { render :json => @resource }
        format.js
      else
        prepare_options
        format.html { render :action => "edit" }
        format.xml  { render :xml => @resource.errors, :status => :unprocessable_entity }
        format.json { render :json => @resource, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /resources/1
  # DELETE /resources/1.xml
  def destroy
    @resource = Resource.find(params[:id])
    @resource.destroy
    flash[:notice] = t('controller.successfully_deleted', :model => t('activerecord.models.resource'))

    respond_to do |format|
      format.html { redirect_to resources_url }
      format.xml  { head :ok }
    end
  end

  private

  def make_query(query, options = {})
    # TODO: integerやstringもqfに含める
    query = query.to_s.strip
    if options[:mode] == 'recent'
      query = "#{query} created_at_d: [NOW-1MONTH TO NOW]"
    end

    #unless options[:carrier_type].blank?
    #  query = "#{query} carrier_type_s: #{options[:carrier_type]}"
    #end

    #unless options[:library].blank?
    #  library_list = options[:library].split.uniq.join(' and ')
    #  query = "#{query} library_sm: #{library_list}"
    #end

    #unless options[:language].blank?
    #  query = "#{query} language_sm: #{options[:language]}"
    #end

    #unless options[:subject].blank?
    #  query = "#{query} subject_sm: #{options[:subject]}"
    #end

    unless options[:tag].blank?
      query = "#{query} tag_sm: #{options[:tag]}"
    end

    unless options[:creator].blank?
      query = "#{query} creator_text: #{options[:creator]}"
    end

    unless options[:contributor].blank?
      query = "#{query} contributor_text: #{options[:contributor]}"
    end

    unless options[:isbn].blank?
      query = "#{query} isbn_sm: #{options[:isbn]}"
    end

    unless options[:issn].blank?
      query = "#{query} issn_s: #{options[:issn]}"
    end

    unless options[:lccn].blank?
      query = "#{query} lccn_s: #{options[:lccn]}"
    end

    unless options[:nbn].blank?
      query = "#{query} nbn_s: #{options[:nbn]}"
    end

    unless options[:publisher].blank?
      query = "#{query} publisher_text: #{options[:publisher]}"
    end

    unless options[:number_of_pages_at_least].blank? and options[:number_of_pages_at_most].blank?
      number_of_pages = {}
      number_of_pages['at_least'] = options[:number_of_pages_at_least].to_i
      number_of_pages['at_most'] = options[:number_of_pages_at_most].to_i
      number_of_pages['at_least'] = "*" if number_of_pages['at_least'] == 0
      number_of_pages['at_most'] = "*" if number_of_pages['at_most'] == 0

      query = "#{query} number_of_pages_i: [#{number_of_pages['at_least']} TO #{number_of_pages['at_most']}]"
    end

    unless options[:pubdate_from].blank? and options[:pubdate_to].blank?
      pubdate = {}
      if options[:pubdate_from].blank?
        pubdate['from'] = "*"
      else
        pubdate['from'] = Time.zone.parse(options[:pubdate_from]).beginning_of_day.utc.iso8601
      end

      if options[:pubdate_to].blank?
        pubdate['to'] = "*"
      else
        pubdate['to'] = Time.zone.parse(options[:pubdate_to]).tomorrow.beginning_of_day.utc.iso8601
      end
      query = "#{query} date_of_publication_d: [#{pubdate['from']} TO #{pubdate['to']}]"
    end

    query = query.strip
    if query == '[* TO *]'
      #  unless params[:advanced_search]
      query = ''
      #  end
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
    when 'pubdate'
      sort[:sort_by] = 'date_of_publication'
      sort[:order] = 'desc'
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
      barcode = Barby::QrCode.new(@resource.id)
      send_data(barcode.to_png.to_blob, :disposition => 'inline', :type => 'image/png')
    when 'holding'
      render :partial => 'manifestations/show_holding', :locals => {:manifestation => @resource}
    when 'tag_edit'
      render :partial => 'manifestations/tag_edit', :locals => {:manifestation => @resource}
    when 'tag_list'
      render :partial => 'manifestations/tag_list', :locals => {:manifestation => @resource}
    when 'show_index'
      render :partial => 'manifestations/show_index', :locals => {:manifestation => @resource}
    when 'show_authors'
      render :partial => 'manifestations/show_authors', :locals => {:manifestation => @resource}
    when 'show_all_authors'
      render :partial => 'manifestations/show_authors', :locals => {:manifestation => @resource}
    when 'pickup'
      render :partial => 'manifestations/pickup', :locals => {:manifestation => @resource}
    when 'screen_shot'
      if @resource.screen_shot
        mime = FileWrapper.get_mime(@resource.screen_shot.path)
        send_file @resource.screen_shot.path, :type => mime, :disposition => 'inline'
      end
    when 'calil_list'
      render :partial => 'manifestations/calil_list', :locals => {:manifestation => @resource}
    else
      false
    end
  end

  def prepare_options
    @carrier_types = CarrierType.all
    @roles = Rails.cache.fetch('role_all'){Role.all}
    @languages = Rails.cache.fetch('language_all'){Language.all}
    @frequencies = Frequency.all
    @nii_types = NiiType.all
  end

  def save_search_history(query, offset = 0, total = 0, user = nil)
    check_dsbl if LibraryGroup.site_config.use_dsbl
    if configatron.write_search_log_to_file
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

end
