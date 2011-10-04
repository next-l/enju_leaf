# -*- encoding: utf-8 -*-
class UsersController < ApplicationController
  #before_filter :reset_params_session
  load_and_authorize_resource
  helper_method :get_patron
  before_filter :store_location, :only => [:index]
  before_filter :clear_search_sessions, :only => [:show]
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  cache_sweeper :user_sweeper, :only => [:create, :update, :destroy]
  #ssl_required :new, :edit, :create, :update, :destroy
  ssl_allowed :index, :show, :new, :edit, :create, :update, :destroy

  def index
    query = params[:query].to_s
    @query = query.dup
    @count = {}

    sort = {:sort_by => 'created_at', :order => 'desc'}
    case params[:sort_by]
    when 'username'
      sort[:sort_by] = 'username'
    end
    case params[:order]
    when 'asc'
      sort[:order] = 'asc'
    when 'desc'
      sort[:order] = 'desc'
    end

    query = params[:query]
    page = params[:page] || 1
    role = current_user.try(:role) || Role.default_role

    unless query.blank?
      @users = User.search do
        fulltext query
        order_by sort[:sort_by], sort[:order]
        with(:required_role_id).less_than role.id
      end.results
    else
      @users = User.order("#{sort[:sort_by]} #{sort[:order]}").page(page)
    end
    @count[:query_result] = @users.total_entries

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @users }
    end
  end

  def show
    if @user == current_user
      redirect_to my_account_url
      return
    end

    session[:user_return_to] = nil
    unless @user.patron
      redirect_to new_user_patron_url(@user); return
    end
    #@tags = @user.owned_tags_by_solr
    @tags = @user.bookmarks.tag_counts.sort{|a,b| a.count <=> b.count}.reverse

    @manifestation = Manifestation.pickup(@user.keyword_list.to_s.split.sort_by{rand}.first) rescue nil

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @user }
    end
  end

  def new
    if user_signed_in?
      unless current_user.has_role?('Librarian')
        access_denied; return
      end
    end
    @user = User.new
    @patron = Patron.new
    @patron.required_role = Role.find_by_name('Librarian')
    @patron.language = Language.where(:iso_639_1 => I18n.default_locale.to_s).first || Language.first
    @patron.country = current_user.library.country

    #@user.openid_identifier = flash[:openid_identifier]
    prepare_options
    @user_groups = UserGroup.all
#    get_patron
#    if @patron.try(:user)
#      flash[:notice] = t('page.already_activated')
#      redirect_to @patron
#      return
#    end
    @user.patron_id = @patron.id if @patron
    logger.error "2: #{@patron.id}"
    @user.library = current_user.library
    @user.locale = current_user.locale
  end

  def edit
    @user.role_id = @user.role.id
    @patron = @user.patron

    if params[:mode] == 'feed_token'
      if params[:disable] == 'true'
        @user.delete_checkout_icalendar_token
      else
        @user.reset_checkout_icalendar_token
      end
      render :partial => 'users/feed_token'
      return
    end
    prepare_options
  end

  def create
    respond_to do |format|
    begin
      Patron.transaction do
        @user = User.create_with_params(params[:user], current_user)
        @user.set_auto_generated_password
        @user.role = Role.where(:name => 'User').first
        @patron = Patron.create_with_user(params[:patron], @user)
        if @user.valid?
          @patron.save!
          @user.patron = @patron
        end
        @user.save!
        flash[:notice] = t('controller.successfully_created.', :model => t('activerecord.models.user'))
        flash[:temporary_password] = @user.password
        format.html { redirect_to user_url(@user) }
        #format.html { redirect_to new_user_patron_url(@user) }
        format.xml  { head :ok }
      end
    rescue ActiveRecord::RecordInvalid
      prepare_options
      @patron.errors.each do |e|
          @user.errors.add(e)
      end
#      flash[:error] = t('user.could_not_setup_account')
      format.html { render :action => "new" }
      format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
    end
    end
  end

  def update
    @user.update_with_params(params[:user], current_user)
    if params[:user][:auto_generated_password] == "1"
      @user.set_auto_generated_password
      flash[:temporary_password] = @user.password
    end

    if current_user.has_role?('Administrator')
      if @user.role_id
        role = Role.find(@user.role_id)
        @user.role = role
      end
    end

    #@user.save do |result|
    respond_to do |format|
      @user.save
      if @user.errors.empty?
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.user'))
        format.html { redirect_to user_url(@user) }
        format.xml  { head :ok }
      else
        prepare_options
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    if @user.deletable_by(current_user)
      @user.destroy
    else
      flash[:notice] = @user.errors[:base].join(' ')
      redirect_to current_user
      return
    end

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  private
  def prepare_options
    @user_groups = UserGroup.all
    @roles = Role.all
    @libraries = Library.all_cache
    @languages = Language.all_cache
    @countries = Country.all_cache
    if @user.active_for_authentication?
      @user.locked = '0'
    else
      @user.locked = '1'
    end
    @patron_types = PatronType.all
  end
end
