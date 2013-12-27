# -*- encoding: utf-8 -*-
class PatronsController < ApplicationController
  add_breadcrumb "I18n.t('page.listing', :model => I18n.t('activerecord.models.patron'))", 'patrons_path'
  add_breadcrumb "I18n.t('activerecord.models.patron')", 'patron_path(params[:id])', :only => [:show]
  add_breadcrumb "I18n.t('page.new', :model => I18n.t('activerecord.models.patron'))", 'new_patron_path', :only => [:new, :create]
  add_breadcrumb "I18n.t('page.editing', :model => I18n.t('activerecord.models.patron'))", 'edit_patron_path(params[:id])', :only => [:edit, :update]
  load_and_authorize_resource :except => :index
  authorize_resource :only => :index
  before_filter :get_user
  helper_method :get_work, :get_expression
  helper_method :get_manifestation, :get_item
  helper_method :get_patron
  helper_method :get_patron_merge_list
  before_filter :prepare_options, :only => [:new, :edit]
  before_filter :store_location
  before_filter :get_version, :only => [:show]
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  cache_sweeper :patron_sweeper, :only => [:create, :update, :destroy]

  include FormInputUtils

  # GET /patrons
  # GET /patrons.json
  def index
    #session[:params] = {} unless session[:params]
    #session[:params][:patron] = params
    # 最近追加されたパトロン
    #@query = params[:query] ||= "[* TO *]"
    if params[:mode] == 'add'
      unless current_user.try(:has_role?, 'Librarian')
        access_denied; return
      end
    end

    query = normalize_query_string(params[:query])
    @query = query.dup

    query = generate_adhoc_one_char_query_text(
      query, Patron, [
        :full_name, :full_name_transcription, :full_name_alternative, # name
        :place, :address_1, :address_2,
        :other_designation, :note,
      ])

    if params[:mode] == 'recent'
      query << 'created_at_d:[NOW-1MONTH TO NOW]'
    end
    logger.debug "  SOLR Query string:<#{query}>"

    order = nil
    @count = {}

    search = Sunspot.new_search(Patron)
    search.data_accessor_for(Patron).include = [
      :patron_type, :required_role
    ]
    search.data_accessor_for(Patron).select = [
      :id,
      :full_name,
      :full_name_transcription,
      :patron_type_id,
      :required_role_id,
      :created_at,
      :date_of_birth,
      :date_of_death,
      :user_id
    ]
    set_role_query(current_user, search)


    unless query.blank?
      search.build do
        fulltext query
      end
    end

    get_work; get_expression; get_manifestation; get_patron; get_patron_merge_list;
    unless params[:mode] == 'add'
      user = @user
      work = @work
      expression = @expression
      manifestation = @manifestation
      patron = @patron
      patron_merge_list = @patron_merge_list
      search.build do
        with(:user).equal_to user.username if user
        with(:work_ids).equal_to work.id if work
        with(:expression_ids).equal_to expression.id if expression
        with(:manifestation_ids).equal_to manifestation.id if manifestation
        with(:original_patron_ids).equal_to patron.id if patron
        with(:patron_merge_list_ids).equal_to patron_merge_list.id if patron_merge_list
      end
    end

    role = current_user.try(:role) || Role.default_role
    search.build do
      with(:required_role_id).less_than role.id
      with(:user_id).equal_to(nil)
      without(:exclude_state).equal_to(1)
    end

    page = params[:page] || 1
    search.query.paginate(page.to_i, Patron.default_per_page)
    @patrons = search.execute!.results

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @patrons }
      format.rss  { render :layout => false }
      format.atom
      format.json { render :json => @patrons }
      format.mobile
    end
  end

  # GET /patrons/1
  # GET /patrons/1.json
  def show
    unless @patron.user.blank?
      access_denied; return
    end

    #get_work; get_expression; get_manifestation; get_item

    case 
    when @work
      @patron = @work.creators.find(params[:id])
    when @manifestation
      @patron = @manifestation.publishers.find(params[:id])
    when @item
      @patron = @item.patrons.find(params[:id])
    else
      if @version
        @patron = @patron.versions.find(@version).item if @version
      end
    end

    patron = @patron
    role = current_user.try(:role) || Role.default_role
    @works = Manifestation.search do
      with(:creator_ids).equal_to patron.id
      with(:required_role_id).less_than_or_equal_to role.id
      paginate :page => params[:work_list_page], :per_page => Manifestation.default_per_page
    end.results
    @expressions = Manifestation.search do
      with(:contributor_ids).equal_to patron.id
      with(:required_role_id).less_than_or_equal_to role.id
      paginate :page => params[:expression_list_page], :per_page => Manifestation.default_per_page
    end.results
    @manifestations = Manifestation.search do
      with(:publisher_ids).equal_to patron.id
      with(:required_role_id).less_than_or_equal_to role.id
      paginate :page => params[:manifestation_list_page], :per_page => Manifestation.default_per_page
    end.results

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @patron }
      format.js
      format.mobile
    end
  end

  # GET /patrons/new
  # GET /patrons/new.json
  def new
    unless current_user.has_role?('Librarian')
      unless current_user == @user
        access_denied; return
      end
    end
    @patron = Patron.new
    if @user
      @patron.user_username = @user.username
      @patron.required_role = Role.find_by_name('Librarian')
    else
      @patron.required_role = Role.find_by_name('Guest')
    end
    @patron.language = Language.where(:iso_639_1 => I18n.default_locale.to_s).first || Language.first
    @patron.country = current_user.library.country
    @patron.country_id = LibraryGroup.site_config.country_id
    @patron.telephone_number_1_type_id = 1
    @patron.telephone_number_2_type_id = 1
    @patron.extelephone_number_1_type_id = 2
    @patron.extelephone_number_2_type_id = 2
    @patron.fax_number_1_type_id = 3
    @patron.fax_number_2_type_id = 3
    prepare_options

    @countalias = 0
    @patron.patron_aliases << PatronAlias.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @patron }
    end
  end

  # GET /patrons/1/edit
  def edit
    @countalias = PatronAlias.count(:conditions => ["patron_id = ?", params[:id]])
    if @countalias == 0
      @patron.patron_aliases << PatronAlias.new
    end
    prepare_options
  end

  # POST /patrons
  # POST /patrons.json
  def create
    @patron = Patron.new(params[:patron])

    if @patron.user_username
      @patron.user = User.find(@patron.user_username) rescue nil
    end
    unless current_user.has_role?('Librarian')
      if @patron.user != current_user
        access_denied; return
      end
    end

    respond_to do |format|
      if @patron.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.patron'))
        case
        when @work
          @work.creators << @patron
          format.html { redirect_to patron_work_url(@patron, @work) }
          format.json { head :created, :location => patron_work_url(@patron, @work) }
        when @expression
          @expression.contributors << @patron
          format.html { redirect_to patron_expression_url(@patron, @expression) }
          format.json { head :created, :location => patron_expression_url(@patron, @expression) }
        when @manifestation
          @manifestation.publishers << @patron
          format.html { redirect_to patron_manifestation_url(@patron, @manifestation) }
          format.json { head :created, :location => patron_manifestation_url(@patron, @manifestation) }
        when @item
          @item.patrons << @patron
          format.html { redirect_to patron_item_url(@patron, @item) }
          format.json { head :created, :location => patron_manifestation_url(@patron, @manifestation) }
        else
          format.html { redirect_to(@patron) }
          format.json { render :json => @patron, :status => :created, :location => @patron }
        end
      else
        prepare_options
        format.html { render :action => "new" }
        format.json { render :json => @patron.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /patrons/1
  # PUT /patrons/1.json
  def update
    respond_to do |format|
      if @patron.update_attributes(params[:patron])
        if params[:checked_item] == 'true'
          flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.user_note'))
          format.html { redirect_to :back }
        else  
          flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.patron'))
          format.html { redirect_to(@patron) }
        end
        format.json { head :no_content }
      else
        prepare_options
        format.html { render :action => "edit" }
        format.json { render :json => @patron.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /patrons/1
  # DELETE /patrons/1.json
  def destroy
    @patron.destroy

    respond_to do |format|
      format.html { redirect_to patrons_url, :notice => t('controller.successfully_deleted', :model => t('activerecord.models.patron')) }
      format.json { head :no_content }
    end
  end

  private
  def prepare_options
    @countries = Country.all_cache
    @patron_types = PatronType.all
    @patron_type_patron_id = PatronType.find_by_name('Person').id 
    @roles = Role.all
    @languages = Language.all_cache
  end
end
