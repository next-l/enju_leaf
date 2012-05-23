# -*- encoding: utf-8 -*-
class PatronsController < ApplicationController
  load_and_authorize_resource :except => :index
  authorize_resource :only => :index
  before_filter :get_user
  before_filter :get_work, :get_expression, :get_manifestation, :get_item, :get_patron, :except => [:update, :destroy]
  if defined?(EnjuResourceMerge)
    before_filter :get_patron_merge_list, :except => [:create, :update, :destroy]
  end
  before_filter :prepare_options, :only => [:new, :edit]
  before_filter :store_location
  before_filter :get_version, :only => [:show]
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  cache_sweeper :patron_sweeper, :only => [:create, :update, :destroy]

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
    query = params[:query].to_s.strip

    if query.size == 1
      query = "#{query}*"
    end

    @query = query.dup
    query = query.gsub('　', ' ')
    order = nil
    @count = {}

    search = Patron.search(:include => [:patron_type, :required_role])
    search.data_accessor_for(Patron).select = [
      :id,
      :full_name,
      :full_name_transcription,
      :patron_type_id,
      :required_role_id,
      :created_at,
      :updated_at,
      :date_of_birth
    ]
    set_role_query(current_user, search)

    if params[:mode] == 'recent'
      query = "#{query} created_at_d:[NOW-1MONTH TO NOW]"
    end
    unless query.blank?
      search.build do
        fulltext query
      end
    end

    unless params[:mode] == 'add'
      user = @user
      work = @work
      manifestation = @manifestation
      patron = @patron
      patron_merge_list = @patron_merge_list
      search.build do
        with(:user).equal_to user.username if user
        with(:work_ids).equal_to work.id if work
        with(:manifestation_ids).equal_to manifestation.id if manifestation
        with(:original_patron_ids).equal_to patron.id if patron
        with(:patron_merge_list_ids).equal_to patron_merge_list.id if patron_merge_list
      end
    end

    role = current_user.try(:role) || Role.default_role
    search.build do
      with(:required_role_id).less_than role.id
    end

    page = params[:page] || 1
    search.query.paginate(page.to_i, Patron.per_page)
    @patrons = search.execute!.results

    flash[:page_info] = {:page => page, :query => query}

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

    @works = @patron.works.page(params[:work_list_page]).per_page(Manifestation.per_page)
    @expressions = @patron.expressions.page(params[:expression_list_page]).per_page(Manifestation.per_page)
    @manifestations = @patron.manifestations.order('date_of_publication DESC').page(params[:manifestation_list_page]).per_page(Manifestation.per_page)

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
    @patron = Patron.new
    @patron.required_role = Role.where(:name => 'Guest').first
    @patron.language = Language.where(:iso_639_1 => I18n.default_locale.to_s).first || Language.first
    @patron.country = current_user.library.country
    prepare_options

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @patron }
    end
  end

  # GET /patrons/1/edit
  def edit
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
        case
        when @work
          @patron.works << @work
        when @manifestation
          @patron.manifestations << @manifestation
        when @item
          @patron.items << @item
        end
        format.html { redirect_to @patron, :notice => t('controller.successfully_created', :model => t('activerecord.models.patron')) }
        format.json { render :json => @patron, :status => :created, :location => @patron }
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
        format.html { redirect_to @patron, :notice => t('controller.successfully_updated', :model => t('activerecord.models.patron')) }
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
    @roles = Role.all
    @languages = Language.all_cache
    @patron_type = PatronType.where(:name => 'Person').first
  end
end
