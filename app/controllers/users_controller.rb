# -*- encoding: utf-8 -*-
class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource :except => :index
  authorize_resource :only => [:index]
  before_filter :get_agent, :only => :new
  before_filter :store_location, :only => [:index]
  before_filter :clear_search_sessions, :only => [:show]
  after_filter :solr_commit, :only => [:create, :update, :destroy]
  #cache_sweeper :user_sweeper, :only => [:create, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    query = flash[:query] = params[:query].to_s
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

    search = User.search
    search.build do
      fulltext query if query
      order_by sort[:sort_by], sort[:order]
      with(:required_role_id).less_than_or_equal_to role.id
    end
    search.query.paginate(page.to_i, User.default_per_page)
    @users = search.execute!.results
    @count[:query_result] = @users.total_entries

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    if @user == current_user
      redirect_to my_account_url
      return
    end

    session[:user_return_to] = nil
    #unless @user.agent
    #  redirect_to new_user_agent_url(@user); return
    #end
    if defined?(EnjuBookmark)
      @tags = @user.bookmarks.tag_counts.sort{|a,b| a.count <=> b.count}.reverse
    end

    @manifestation = Manifestation.pickup(@user.keyword_list.to_s.split.sort_by{rand}.first) rescue nil

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    unless current_user.try(:has_role?, 'Librarian')
      access_denied; return
    end
    @user = User.new
    prepare_options
    @user_groups = UserGroup.all
    if @agent.try(:user)
      flash[:notice] = t('user.already_activated')
      redirect_to @agent
      return
    end
    @user.agent_id = @agent.id if @agent
    @user.library = current_user.library
    @user.locale = current_user.locale
  end

  # GET /agents/1/edit
  def edit
    if @user == current_user
      redirect_to edit_my_account_url
      return
    end

    if defined?(EnjuCirculation)
      if params[:mode] == 'feed_token'
        if params[:disable] == 'true'
          @user.delete_checkout_icalendar_token
        else
          @user.reset_checkout_icalendar_token
        end
        render :partial => 'users/feed_token'
        return
      end
    end
    prepare_options
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new
    @user.assign_attributes(params[:user], :as => :admin)
    @user.operator = current_user
    @user.set_auto_generated_password

    respond_to do |format|
      if @user.save
        role = Role.where(:name => 'User').first
        user_has_role = UserHasRole.new
        user_has_role.assign_attributes({:user_id => @user.id, :role_id => role.id}, :as => :admin)
        user_has_role.save
        flash[:temporary_password] = @user.password
        format.html { redirect_to @user, :notice => t('controller.successfully_created', :model => t('activerecord.models.user')) }
        format.json { render :json => @user, :status => :created, :location => @user }
      else
        prepare_options
        flash[:error] = t('user.could_not_setup_account')
        format.html { render :action => "new" }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    if current_user.has_role?('Librarian')
      @user.assign_attributes(params[:user], :as => :admin)
    else
      @user.assign_attributes(params[:user])
    end
    if @user.auto_generated_password == "1"
      @user.set_auto_generated_password
      flash[:temporary_password] = @user.password
    end

    respond_to do |format|
      @user.save
      if @user.errors.empty?
        format.html { redirect_to @user, :notice => t('controller.successfully_updated', :model => t('activerecord.models.user')) }
        format.json { head :no_content }
      else
        prepare_options
        format.html { render :action => "edit" }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
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
      format.json { head :no_content }
    end
  end

  private
  def prepare_options
    @user_groups = UserGroup.all
    @roles = Role.all
    @libraries = Library.all_cache
    @languages = Language.all_cache
    if @user.active_for_authentication?
      @user.locked = '0'
    else
      @user.locked = '1'
    end
  end

  def set_user
    @user = User.friendly.find(params[:id])
  end
end
