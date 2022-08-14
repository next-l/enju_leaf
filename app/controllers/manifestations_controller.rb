class ManifestationsController < ApplicationController
  before_action :set_manifestation, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :authenticate_user!, only: :edit
  before_action :get_agent, :get_manifestation, except: [:create, :update, :destroy]
  before_action :get_expression, only: :new
  if defined?(EnjuSubject)
    before_action :get_subject, except: [:create, :update, :destroy]
  end
  before_action :get_series_statement, only: [:index, :new, :edit]
  before_action :get_item, :get_libraries, only: :index
  before_action :prepare_options, only: [:new, :edit]
  after_action :convert_charset, only: :index

  # GET /manifestations
  # GET /manifestations.json
  def index
    mode = params[:mode]
    if mode == 'add'
      unless current_user.try(:has_role?, 'Librarian')
        access_denied
        return
      end
    end

    @seconds = Benchmark.realtime do
      set_reservable if defined?(EnjuCirculation)

      sort, @count = {}, {}
      query = ""

      if request.format.text?
        per_page = 65534
      end

      if params[:api] == 'openurl'
        openurl = Openurl.new(params)
        @manifestations = openurl.search
        query = openurl.query_text
        sort = set_search_result_order(params[:sort_by], params[:order])
      else
        query = make_query(params[:query], params)
        sort = set_search_result_order(params[:sort_by], params[:order])
      end

      # 絞り込みを行わない状態のクエリ
      @query = query.dup
      query = query.gsub('　', ' ')

      includes = [:series_statements]
      includes << :classifications if defined?(EnjuSubject)
      includes << :bookmarks if defined?(EnjuBookmark)
      search = Manifestation.search(include: includes)
      case @reservable
      when 'true'
        reservable = true
      when 'false'
        reservable = false
      else
        reservable = nil
      end

      agent = get_index_agent
      @index_agent = agent
      manifestation = @manifestation if @manifestation
      series_statement = @series_statement if @series_statement
      parent = @parent = Manifestation.find_by(id: params[:parent_id]) if params[:parent_id].present?

      if defined?(EnjuSubject)
        subject = @subject if @subject
      end

      unless mode == 'add'
        search.build do
          with(:creator_ids).equal_to agent[:creator].id if agent[:creator]
          with(:contributor_ids).equal_to agent[:contributor].id if agent[:contributor]
          with(:publisher_ids).equal_to agent[:publisher].id if agent[:publisher]
          with(:series_statement_ids).equal_to series_statement.id if series_statement
          with(:parent_ids).equal_to parent.id if parent
        end
      end

      search.build do
        fulltext query if query.present?
        order_by sort[:sort_by], sort[:order]
        if defined?(EnjuSubject)
          with(:subject_ids).equal_to subject.id if subject
        end
        unless parent
          if params[:serial].to_s.downcase == "true"
            with(:series_master).equal_to true unless parent
            with(:serial).equal_to true
            #if series_statement.serial?
            #  if mode != 'add'
            #    order_by :volume_number, sort[:order]
            #    order_by :issue_number, sort[:order]
            #    order_by :serial_number, sort[:order]
            #  end
            #else
            #  with(:serial).equal_to false
            #end
          elsif mode != 'add'
            with(:resource_master).equal_to true
          end
        end
        facet :reservable if defined?(EnjuCirculation)
      end
      search = make_internal_query(search)
      search.data_accessor_for(Manifestation).select = [
        :id,
        :original_title,
        :title_transcription,
        :required_role_id,
        :carrier_type_id,
        :access_address,
        :volume_number_string,
        :issue_number_string,
        :serial_number_string,
        :date_of_publication,
        :pub_date,
        :language_id,
        :created_at,
        :updated_at,
        :volume_number_string,
        :volume_number,
        :issue_number_string,
        :issue_number,
        :serial_number,
        :edition_string,
        :edition,
        :serial,
        :statement_of_responsibility
      ] if params[:format] == 'html' or params[:format].nil?
      all_result = search.execute
      @count[:query_result] = all_result.total
      @reservable_facet = all_result.facet(:reservable).rows if defined?(EnjuCirculation)
      max_number_of_results = @library_group.max_number_of_results
      if max_number_of_results == 0
        @max_number_of_results = @count[:query_result]
      else
        @max_number_of_results = max_number_of_results
      end

      if params[:format] == 'html' or params[:format].nil?
        @search_query = Digest::SHA1.hexdigest(Marshal.dump(search.query.to_params).force_encoding('UTF-8'))
        if flash[:search_query] == @search_query
          flash.keep(:search_query)
        elsif @series_statement
          flash.keep(:search_query)
        else
          flash[:search_query] = @search_query
          @manifestation_ids = search.build do
            paginate page: 1, per_page: @max_number_of_results
          end.execute.raw_results.collect(&:primary_key).map{|id| id.to_i}
        end

        if defined?(EnjuBookmark)
          if params[:view] == 'tag_cloud'
            unless @manifestation_ids
              @manifestation_ids = search.build do
                paginate page: 1, per_page: @max_number_of_results
              end.execute.raw_results.collect(&:primary_key).map{|id| id.to_i}
            end
            #bookmark_ids = Bookmark.where(manifestation_id: flash[:manifestation_ids]).limit(1000).pluck(:id)
            bookmark_ids = Bookmark.where(manifestation_id: @manifestation_ids).limit(1000).pluck(:id)
            @tags = Tag.bookmarked(bookmark_ids)
            render partial: 'manifestations/tag_cloud'
            return
          end
        end
      end

      page ||= params[:page] || 1
      if params[:per_page].to_i.positive?
        per_page = params[:per_page].to_i
      else
        per_page = Manifestation.default_per_page
      end

      pub_dates = parse_pub_date(params)
      pub_date_range = {}

      if pub_dates[:from] == '*'
        pub_date_range[:from] = 0
      else
        pub_date_range[:from] = Time.zone.parse(pub_dates[:from]).year
      end
      if pub_dates[:until] == '*'
        pub_date_range[:until] = 10000
      else
        pub_date_range[:until] = Time.zone.parse(pub_dates[:until]).year
      end

      if params[:pub_year_range_interval]
        pub_year_range_interval = params[:pub_year_range_interval].to_i
      else
        pub_year_range_interval = @library_group.pub_year_facet_range_interval || 10
      end

      search.build do
        facet :reservable if defined?(EnjuCirculation)
        facet :carrier_type
        facet :library
        facet :language
        facet :pub_year, range: pub_date_range[:from]..pub_date_range[:until], range_interval: pub_year_range_interval
        facet :subject_ids if defined?(EnjuSubject)
        paginate page: page.to_i, per_page: per_page
      end

      search_result = search.execute
      if @count[:query_result] > @max_number_of_results
        max_count = @max_number_of_results
      else
        max_count = @count[:query_result]
      end
      @manifestations = Kaminari.paginate_array(
        search_result.results, total_count: max_count
      ).page(page).per(per_page)

      if params[:format].blank? or params[:format] == 'html'
        @carrier_type_facet = search_result.facet(:carrier_type).rows
        @language_facet = search_result.facet(:language).rows
        @library_facet = search_result.facet(:library).rows
        @pub_year_facet = search_result.facet(:pub_year).rows.reverse
      end

      @search_engines = SearchEngine.order(:position)

      if defined?(EnjuSearchLog)
        if current_user.try(:save_search_history)
          current_user.save_history(query, @manifestations.offset_value + 1, @count[:query_result], params[:format])
        end
      end
    end

    respond_to do |format|
      format.html
      format.html.phone
      format.xml
      format.rss  { render layout: false }
      format.text { render layout: false }
      format.rdf { render layout: false }
      format.atom
      format.mods
      format.json
      format.js
      format.xlsx
    end
  end

  # GET /manifestations/1
  # GET /manifestations/1.json
  def show
    case params[:mode]
    when 'send_email'
      if user_signed_in?
        Notifier.manifestation_info(current_user.id, @manifestation.id).deliver_later
        flash[:notice] = t('page.sent_email')
        redirect_to manifestation_url(@manifestation)
        return
      else
        access_denied
        return
      end
    end

    return if render_mode(params[:mode])

    flash.keep(:search_query)

    if @manifestation.series_master?
      flash.keep(:notice) if flash[:notice]
      flash[:manifestation_id] = @manifestation.id
      redirect_to manifestations_url(parent_id: @manifestation.id)
      return
    end

    if defined?(EnjuCirculation)
      @reserved_count = Reserve.waiting.where(manifestation_id: @manifestation.id, checked_out_at: nil).count
      @reserve = current_user.reserves.where(manifestation_id: @manifestation.id).first if user_signed_in?
    end

    if defined?(EnjuQuestion)
      @questions = @manifestation.questions(user: current_user, page: params[:question_page])
    end

    if @manifestation.attachment.path
      if ENV['ENJU_STORAGE'] == 's3'
        data = Faraday.get(@manifestation.attachment.expiring_url).body.force_encoding('UTF-8')
      else
        file = File.expand_path(@manifestation.attachment.path)
      end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.html.phone
      format.xml {
        case params[:mode]
        when 'related'
          render template: 'manifestations/related'
        else
          render xml: @manifestation
        end
      }
      format.rdf
      format.mods
      format.json
      format.text
      format.js
      format.xlsx
      format.download {
        if @manifestation.attachment.path
          if ENV['ENJU_STORAGE'] == 's3'
            send_data data, filename: File.basename(@manifestation.attachment_file_name), type: 'application/octet-stream'
          elsif File.exist?(file) && File.file?(file)
            send_file file, filename: File.basename(@manifestation.attachment_file_name), type: 'application/octet-stream'
          end
        else
          render template: 'page/404', status: :not_found
        end
      }
    end
  end

  # GET /manifestations/new
  def new
    @manifestation = Manifestation.new
    @manifestation.language = Language.find_by(iso_639_1: @locale)
    @parent = Manifestation.find_by(id: params[:parent_id]) if params[:parent_id].present?
    if @parent
      @manifestation.parent_id = @parent.id
      [:original_title, :title_transcription,
        :serial, :title_alternative, :statement_of_responsibility, :publication_place,
        :height, :width, :depth, :price, :access_address, :language, :frequency, :required_role,
].each do |attribute|
        @manifestation.send("#{attribute}=", @parent.send(attribute))
      end
      [:creators, :contributors, :publishers, :classifications, :subjects].each do |attribute|
        @manifestation.send(attribute).build(@parent.send(attribute).collect(&:attributes))
      end
    end
  end

  # GET /manifestations/1/edit
  def edit
    unless current_user.has_role?('Librarian')
      unless params[:mode] == 'tag_edit'
        access_denied
        return
      end
    end
    if defined?(EnjuBookmark)
      if params[:mode] == 'tag_edit'
        @bookmark = current_user.bookmarks.where(manifestation_id: @manifestation.id).first if @manifestation rescue nil
        render partial: 'manifestations/tag_edit', locals: {manifestation: @manifestation}
      end
    end
  end

  # POST /manifestations
  # POST /manifestations.json
  def create
    @manifestation = Manifestation.new(manifestation_params)
    parent = Manifestation.find_by(id: @manifestation.parent_id)
    unless @manifestation.original_title?
      @manifestation.original_title = @manifestation.attachment_file_name
    end

    respond_to do |format|
      if @manifestation.save
        Manifestation.transaction do
          set_creators

          if parent
            parent.derived_manifestations << @manifestation
            parent.index
            @manifestation.index
          end

          Sunspot.commit
        end

        format.html { redirect_to @manifestation, notice: t('controller.successfully_created', model: t('activerecord.models.manifestation')) }
        format.json { render json: @manifestation, status: :created, location: @manifestation }
      else
        prepare_options
        format.html { render action: "new" }
        format.json { render json: @manifestation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /manifestations/1
  # PUT /manifestations/1.json
  def update
    @manifestation.assign_attributes(manifestation_params)

    respond_to do |format|
      if @manifestation.save
        set_creators
        
        format.html { redirect_to @manifestation, notice: t('controller.successfully_updated', model: t('activerecord.models.manifestation')) }
        format.json { head :no_content }
      else
        prepare_options
        format.html { render action: "edit" }
        format.json { render json: @manifestation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /manifestations/1
  # DELETE /manifestations/1.json
  def destroy
    # workaround
    @manifestation.identifiers.destroy_all
    @manifestation.creators.destroy_all
    @manifestation.contributors.destroy_all
    @manifestation.publishers.destroy_all
    @manifestation.bookmarks.destroy_all if defined?(EnjuBookmark)
    @manifestation.reload
    @manifestation.destroy

    respond_to do |format|
      format.html { redirect_to manifestations_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.manifestation')) }
      format.json { head :no_content }
    end
  end

  private
  def set_manifestation
    @manifestation = Manifestation.find(params[:id])
    authorize @manifestation
  end

  def check_policy
    authorize Manifestation
  end

  def manifestation_params
    params.require(:manifestation).permit(
      :original_title, :title_alternative, :title_transcription,
      :manifestation_identifier, :date_copyrighted,
      :access_address, :language_id, :carrier_type_id, :start_page,
      :end_page, :height, :width, :depth, :publication_place,
      :price, :fulltext, :volume_number_string,
      :issue_number_string, :serial_number_string, :edition, :note,
      :repository_content, :required_role_id, :frequency_id,
      :title_alternative_transcription, :description, :abstract, :available_at,
      :valid_until, :date_submitted, :date_accepted, :date_captured,
      :ndl_bib_id, :pub_date, :edition_string, :volume_number, :issue_number,
      :serial_number, :content_type_id, :attachment, :lock_version,
      :dimensions, :fulltext_content, :extent, :memo,
      :parent_id, :delete_attachment,
      :serial, :statement_of_responsibility,
      {creators_attributes: [
        :id, :last_name, :middle_name, :first_name,
        :last_name_transcription, :middle_name_transcription,
        :first_name_transcription, :corporate_name,
        :corporate_name_transcription,
        :full_name, :full_name_transcription, :full_name_alternative,
        :other_designation, :language_id,
        :country_id, :agent_type_id, :note, :required_role_id, :email, :url,
        :full_name_alternative_transcription, :title,
        :agent_identifier, :agent_id,
        :_destroy
      ]},
      {contributors_attributes: [
        :id, :last_name, :middle_name, :first_name,
        :last_name_transcription, :middle_name_transcription,
        :first_name_transcription, :corporate_name,
        :corporate_name_transcription,
        :full_name, :full_name_transcription, :full_name_alternative,
        :other_designation, :language_id,
        :country_id, :agent_type_id, :note, :required_role_id, :email, :url,
        :full_name_alternative_transcription, :title,
        :agent_identifier,
        :_destroy
      ]},
      {publishers_attributes: [
        :id, :last_name, :middle_name, :first_name,
        :last_name_transcription, :middle_name_transcription,
        :first_name_transcription, :corporate_name,
        :corporate_name_transcription,
        :full_name, :full_name_transcription, :full_name_alternative,
        :other_designation, :language_id,
        :country_id, :agent_type_id, :note, :required_role_id, :email, :url,
        :full_name_alternative_transcription, :title,
        :agent_identifier,
        :_destroy
      ]},
      {series_statements_attributes: [
        :id, :original_title, :numbering, :title_subseries,
        :numbering_subseries, :title_transcription, :title_alternative,
        :title_subseries_transcription, :creator_string, :volume_number_string,
        :volume_number_transcription_string, :series_master,
        :_destroy
      ]},
      {subjects_attributes: [
        :id, :parent_id, :use_term_id, :term, :term_transcription,
        :subject_type_id, :note, :required_role_id, :subject_heading_type_id,
        :_destroy
      ]},
      {classifications_attributes: [
        :id, :parent_id, :category, :note, :classification_type_id,
        :_destroy
      ]},
      {identifiers_attributes: [
        :id, :body, :identifier_type_id,
        :_destroy
      ]},
      {manifestation_custom_values_attributes: [
        :id, :manifestation_custom_property_id, :manifestation_id, :value,:_destroy
      ]}
    )
  end

  def make_query(query, options = {})
    # TODO: integerやstringもqfに含める
    query = query.to_s.strip

    if query.size == 1
      query = "#{query}*"
    end

    if options[:mode] == 'recent'
      query = "#{query} created_at_d:[NOW-1MONTH TO NOW]"
    end

    #unless options[:carrier_type].blank?
    #  query = "#{query} carrier_type_s:#{options[:carrier_type]}"
    #end

    if options[:library_adv].present?
      library_list = options[:library_adv].split.uniq.join(' OR ')
      query = "#{query} library_sm:(#{library_list})"
    end
    shelf_list = []
    options.keys.grep(/_shelf\Z/).each do |library_shelf|
      library_name = library_shelf.sub(/_shelf\Z/, "")
      options[library_shelf].each do |shelf|
        shelf_list << "#{library_name}_#{shelf}"
      end
    end
    if shelf_list.present?
      query += " shelf_sm:(#{shelf_list.join(" OR ")})"
    end

    #unless options[:language].blank?
    #  query = "#{query} language_sm:#{options[:language]}"
    #end

    if options[:subject].present?
      query = "#{query} subject_sm:#{options[:subject]}"
    end
    if options[:subject_text].present?
      query = "#{query} subject_text:#{options[:subject_text]}"
    end
    if options[:classification].present? and options[:classification_type].present?
      classification_type = ClassificationType.find(options[:classification_type]).name
      query = "#{query} classification_sm:#{classification_type}_#{options[:classification]}*"
    end

    if options[:title].present?
      query = "#{query} title_text:#{options[:title]}"
    end

    if options[:tag].present?
      query = "#{query} tag_sm:#{options[:tag]}"
    end

    if options[:creator].present?
      query = "#{query} creator_text:#{options[:creator]}"
    end

    if options[:contributor].present?
      query = "#{query} contributor_text:#{options[:contributor]}"
    end

    if options[:isbn].present?
      query = "#{query} isbn_sm:#{options[:isbn].gsub('-', '')}"
    end

    if options[:isbn_id].present?
      query = "#{query} isbn_sm:#{options[:isbn_id].gsub('-', '')}"
    end

    if options[:issn].present?
      query = "#{query} issn_sm:#{options[:issn].gsub('-', '')}"
    end

    if options[:lccn].present?
      query = "#{query} lccn_s:#{options[:lccn]}"
    end

    if options[:jpno].present?
      query = "#{query} jpno_s:#{options[:jpno]}"
    end

    if options[:publisher].present?
      query = "#{query} publisher_text:#{options[:publisher]}"
    end

    if options[:call_number].present?
      query = "#{query} call_number_sm:#{options[:call_number]}*"
    end

    if options[:item_identifier].present?
      query = "#{query} item_identifier_sm:#{options[:item_identifier]}"
    end

    unless options[:number_of_pages_at_least].blank? && options[:number_of_pages_at_most].blank?
      number_of_pages = {}
      number_of_pages[:at_least] = options[:number_of_pages_at_least].to_i
      number_of_pages[:at_most] = options[:number_of_pages_at_most].to_i
      number_of_pages[:at_least] = "*" if number_of_pages[:at_least] == 0
      number_of_pages[:at_most] = "*" if number_of_pages[:at_most] == 0

      query = "#{query} number_of_pages_i:[#{number_of_pages[:at_least]} TO #{number_of_pages[:at_most]}]"
    end

    query = set_pub_date(query, options)
    query = set_acquisition_date(query, options)

    query = query.strip
    if query == '[* TO *]'
      #  unless params[:advanced_search]
      query = ''
      #  end
    end

    query
  end

  def set_search_result_order(sort_by, order)
    sort = {}
    if sort_by.try(:"include?", ":")
      sort_by, order = sort_by.split(/:/)
    end
    # TODO: ページ数や大きさでの並べ替え
    case sort_by
    when 'title'
      sort[:sort_by] = 'sort_title'
      sort[:order] = 'asc'
    when 'pub_date'
      sort[:sort_by] = 'date_of_publication'
      sort[:order] = 'desc'
    when 'score'
      sort[:sort_by] = 'score'
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
    when 'holding'
      render partial: 'manifestations/show_holding', locals: {manifestation: @manifestation}
    when 'tag_edit'
      if defined?(EnjuBookmark)
        render partial: 'manifestations/tag_edit', locals: {manifestation: @manifestation}
      end
    when 'tag_list'
      if defined?(EnjuBookmark)
        render partial: 'manifestations/tag_list', locals: {manifestation: @manifestation}
      end
    when 'show_index'
      render partial: 'manifestations/show_index', locals: {manifestation: @manifestation}
    when 'show_creators'
      render partial: 'manifestations/show_creators', locals: {manifestation: @manifestation}
    when 'show_all_creators'
      render partial: 'manifestations/show_creators', locals: {manifestation: @manifestation}
    when 'pickup'
      render partial: 'manifestations/pickup', locals: {manifestation: @manifestation}
    when 'calil_list'
      if defined?(EnjuCalil)
        render partial: 'manifestations/calil_list', locals: {manifestation: @manifestation}
      end
    else
      false
    end
  end

  def prepare_options
    @carrier_types = CarrierType.order(:position).select([:id, :display_name, :position])
    @content_types = ContentType.order(:position).select([:id, :display_name, :position])
    @roles = Role.select([:id, :display_name, :position])
    @languages = Language.order(:position).select([:id, :display_name, :position])
    @frequencies = Frequency.order(:position).select([:id, :display_name, :position])
    @identifier_types = IdentifierType.order(:position).select([:id, :display_name, :position])
    @nii_types = NiiType.select([:id, :display_name, :position]) if defined?(EnjuNii)
    if defined?(EnjuSubject)
      @subject_types = SubjectType.select([:id, :display_name, :position])
      @subject_heading_types = SubjectHeadingType.select([:id, :display_name, :position])
      @classification_types = ClassificationType.select([:id, :display_name, :position])
    end
  end

  def get_index_agent
    agent = {}
    case
    when params[:agent_id]
      agent[:agent] = Agent.find(params[:agent_id])
    when params[:creator_id]
      agent[:creator] = @creator = Agent.find(params[:creator_id])
    when params[:contributor_id]
      agent[:contributor] = @contributor = Agent.find(params[:contributor_id])
    when params[:publisher_id]
      agent[:publisher] = @publisher = Agent.find(params[:publisher_id])
    end
    agent
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

  def parse_pub_date(options)
    pub_date = {}
    if options[:pub_date_from].blank?
      pub_date[:from] = "*"
    else
      year = options[:pub_date_from].to_s.gsub(/\D/, '').rjust(4, "0")
      if year.length == 4
        pub_date[:from] = Time.zone.parse(Time.utc(year).to_s).beginning_of_year.utc.iso8601
      else
        pub_date[:from] = Time.zone.parse(options[:pub_date_from]).beginning_of_day.utc.iso8601 rescue nil
      end
      unless pub_date[:from]
        pub_date[:from] = Time.zone.parse(Time.utc(options[:pub_date_from]).to_s).beginning_of_day.utc.iso8601
      end
    end

    if options[:pub_date_until].blank?
      pub_date[:until] = "*"
    else
      year = options[:pub_date_until].to_s.gsub(/\D/, '').rjust(4, "0")
      if year.length == 4
        pub_date[:until] = Time.zone.parse(Time.utc(year).to_s).end_of_year.utc.iso8601
      else
        pub_date[:until] = Time.zone.parse(options[:pub_date_until]).end_of_day.utc.iso8601 rescue nil
      end
      unless pub_date[:until]
        pub_date[:until] = Time.zone.parse(Time.utc(options[:pub_date_until]).to_s).end_of_year.utc.iso8601
      end
    end
    pub_date
  end

  def set_pub_date(query, options)
    unless options[:pub_date_from].blank? && options[:pub_date_until].blank?
      pub_date = parse_pub_date(options)
      query = "#{query} date_of_publication_d:[#{pub_date[:from]} TO #{pub_date[:until]}]"
    end
    query
  end

  def set_acquisition_date(query, options)
    unless options[:acquired_from].blank? && options[:acquired_until].blank?
      options[:acquired_from].to_s.gsub!(/\D/, '')
      options[:acquired_until].to_s.gsub!(/\D/, '')

      acquisition_date = {}
      if options[:acquired_from].blank?
        acquisition_date[:from] = "*"
      else
        year = options[:acquired_from].rjust(4, "0")
        if year.length == 4
          acquisition_date[:from] = Time.zone.parse(Time.utc(year).to_s).beginning_of_year.utc.iso8601
        else
          acquisition_date[:from] = Time.zone.parse(options[:acquired_from]).beginning_of_day.utc.iso8601 rescue nil
        end
        unless acquisition_date[:from]
          acquisition_date[:from] = Time.zone.parse(Time.utc(options[:acquired_from]).to_s).beginning_of_day.utc.iso8601
        end
      end

      if options[:acquired_until].blank?
        acquisition_date[:until] = "*"
      else
        year = options[:acquired_until].rjust(4, "0")
        if year.length == 4
          acquisition_date[:until] = Time.zone.parse(Time.utc(year).to_s).end_of_year.utc.iso8601
        else
          acquisition_date[:until] = Time.zone.parse(options[:acquired_until]).end_of_day.utc.iso8601 rescue nil
        end
        unless acquisition_date[:until]
          acquisition_date[:until] = Time.zone.parse(Time.utc(options[:acquired_until]).to_s).end_of_year.utc.iso8601
        end
      end

      query = "#{query} acquired_at_d:[#{acquisition_date[:from]} TO #{acquisition_date[:until]}]"
    end
    query
  end

  def set_creators
    creators_params = manifestation_params[:creators_attributes]
    contributors_params = manifestation_params[:contributors_attributes]
    publishers_params = manifestation_params[:publishers_attributes]

    Manifestation.transaction do
      @manifestation.creates.destroy_all
      @manifestation.realizes.destroy_all
      @manifestation.produces.destroy_all
      @manifestation.reload

      @manifestation.creators = Agent.new_agents(creators_params)
      @manifestation.contributors = Agent.new_agents(contributors_params)
      @manifestation.publishers = Agent.new_agents(publishers_params)
    end
  end
end
