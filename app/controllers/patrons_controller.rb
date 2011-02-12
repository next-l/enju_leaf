# -*- encoding: utf-8 -*-
class PatronsController < ApplicationController
  load_and_authorize_resource
  before_filter :get_user_if_nil
  helper_method :get_work, :get_expression
  helper_method :get_manifestation, :get_item
  helper_method :get_patron
  helper_method :get_patron_merge_list
  before_filter :prepare_options, :only => [:new, :edit]
  before_filter :store_location
  before_filter :get_version, :only => [:show]
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  cache_sweeper :patron_sweeper, :only => [:create, :update, :destroy]
  
  # GET /patrons
  # GET /patrons.xml
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
      :required_role_id
    ]
    set_role_query(current_user, search)

    if params[:mode] == 'recent'
      query = "#{query} created_at_d: [NOW-1MONTH TO NOW]"
    end
    unless query.blank?
      search.build do
        fulltext query
      end
    end
    unless params[:mode] == 'add'
      user = @user
      work = get_work
      expression = get_expression
      manifestation = get_manifestation
      patron = get_patron
      patron_merge_list = get_patron_merge_list
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
    end

    page = params[:page] || 1
    begin
      search.query.paginate(page.to_i, Patron.per_page)
      @patrons = search.execute!.results
    rescue RSolr::RequestError
      @patrons = WillPaginate::Collection.create(1,1,0) do end
    end

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @patrons }
      format.rss  { render :layout => false }
      format.atom
      format.json { render :json => @patrons }
      format.mobile
    end
  rescue RSolr::RequestError
    flash[:notice] = t('page.error_occured')
    redirect_to patrons_url
    return
  end

  # GET /patrons/1
  # GET /patrons/1.xml
  def show
    get_work; get_expression; get_manifestation; get_item
    case
    when @work
      @patron = @work.creators.find(params[:id])
    when @expression
      @patron = @expression.contributors.find(params[:id])
    when @manifestation
      @patron = @manifestation.publishers.find(params[:id])
    when @item
      @patron = @item.patrons.find(params[:id])
    else
      if @version
        @patron = @patron.versions.find(@version).item if @version
      else
        @patron = Patron.find(params[:id])
      end
    end

    @works = @patron.works.paginate(:page => params[:work_list_page], :per_page => Manifestation.per_page)
    @expressions = @patron.expressions.paginate(:page => params[:expression_list_page], :per_page => Manifestation.per_page)
    @manifestations = @patron.manifestations.paginate(:page => params[:manifestation_list_page], :order => 'date_of_publication DESC', :per_page => Manifestation.per_page)

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @patron }
      format.js
      format.mobile
    end
  end

  # GET /patrons/new
  def new
    unless current_user.has_role?('Librarian')
      unless current_user == @user
        access_denied; return
      end
    end
    @patron = Patron.new
    if @user
      @patron.user = @user
      @patron.required_role = Role.find_by_name('Librarian')
    else
      @patron.required_role = Role.find_by_name('Guest')
    end
    @patron.language = Language.first(:conditions => {:iso_639_1 => I18n.default_locale.to_s}) || Language.first
    @patron.country = current_user.library.country
    prepare_options

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @patron }
    end
  end

  # GET /patrons/1;edit
  def edit
    #@patron = Patron.find(params[:id])
    prepare_options
  end

  # POST /patrons
  # POST /patrons.xml
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
          format.xml  { head :created, :location => patron_work_url(@patron, @work) }
        when @expression
          @expression.contributors << @patron
          format.html { redirect_to patron_expression_url(@patron, @expression) }
          format.xml  { head :created, :location => patron_expression_url(@patron, @expression) }
        when @manifestation
          @manifestation.publishers << @patron
          format.html { redirect_to patron_manifestation_url(@patron, @manifestation) }
          format.xml  { head :created, :location => patron_manifestation_url(@patron, @manifestation) }
        when @item
          @item.patrons << @patron
          format.html { redirect_to patron_item_url(@patron, @item) }
          format.xml  { head :created, :location => patron_manifestation_url(@patron, @manifestation) }
        else
          format.html { redirect_to(@patron) }
          format.xml  { render :xml => @patron, :status => :created, :location => @patron }
        end
      else
        prepare_options
        format.html { render :action => "new" }
        format.xml  { render :xml => @patron.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /patrons/1
  # PUT /patrons/1.xml
  def update
    #@patron = Patron.find(params[:id])

    respond_to do |format|
      if @patron.update_attributes(params[:patron])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.patron'))
        format.html { redirect_to patron_url(@patron) }
        format.xml  { head :ok }
      else
        prepare_options
        format.html { render :action => "edit" }
        format.xml  { render :xml => @patron.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /patrons/1
  # DELETE /patrons/1.xml
  def destroy
    #@patron = Patron.find(params[:id])

    if @patron.user.try(:has_role?, 'Librarian')
      unless current_user.has_role?('Administrator')
        access_denied
        return
      end
    end

    @patron.destroy

    respond_to do |format|
      flash[:notice] = t('controller.successfully_deleted', :model => t('activerecord.models.patron'))
      format.html { redirect_to patrons_url }
      format.xml  { head :ok }
    end
  end

  private
  def prepare_options
    @countries = Country.all_cache
    @patron_types = PatronType.all
    @roles = Role.all_cache
    @languages = Language.all_cache
  end

end
