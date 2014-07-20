# -*- encoding: utf-8 -*-
class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :store_location, :only => [:index]
  before_action :clear_search_sessions, :only => [:show]
  after_action :verify_authorized

  # GET /users
  # GET /users.json
  def index
    authorize User
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

    if params[:query].to_s.strip == ''
      user_query = '*'
    else
      user_query = params[:query]
    end
    if user_signed_in?
      role_ids = Role.where('id <= ?', current_user.role.id).pluck(:id)
    else
      role_ids = [1]
    end

    query = {
      query: {
        filtered: {
          query: {
            query_string: {
              query: user_query, fields: ['_all']
            }
          }
        }
      },
      sort: [
        {:"#{sort[:sort_by]}" => sort[:order]}
      ]
    }

    search = User.search(query, routing: role_ids)
    @users = search.page(params[:page]).records
    #search.build do
    #  order_by sort[:sort_by], sort[:order]
    #end

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
      format.html.phone
      format.json { render :json => @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    #unless current_user.try(:has_role?, 'Librarian')
    #  access_denied; return
    #end
    @user = User.new
    authorize @user
    prepare_options
    @user_groups = UserGroup.all
    @user.user_group = current_user.user_group
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
    authorize User
    @user = User.new(user_params)
    @user.operator = current_user
    @user.set_auto_generated_password

    respond_to do |format|
      if @user.save
        role = Role.where(:name => 'User').first
        user_has_role = UserHasRole.new
        user_has_role.assign_attributes({:user_id => @user.id, :role_id => role.id})
        user_has_role.save
        flash[:temporary_password] = @user.password
        format.html { redirect_to @user, notice: t('controller.successfully_created', :model => t('activerecord.models.user')) }
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
    @user.assign_attributes(user_params)
    if @user.auto_generated_password == "1"
      @user.set_auto_generated_password
      flash[:temporary_password] = @user.password
    end

    respond_to do |format|
      @user.save
      if @user.errors.empty?
        format.html { redirect_to @user, notice: t('controller.successfully_updated', :model => t('activerecord.models.user')) }
        format.json { head :no_content }
      else
        prepare_options
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
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
      format.html { redirect_to users_url, notice: t('controller.successfully_destroyed', :model => t('activerecord.models.user')) }
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
    authorize @user
  end

  def user_params
    if current_user.has_role?('Librarian')
      params.require(:user).permit(
        :email, :password, :password_confirmation, :username,
        :current_password, :user_number, :remember_me,
        :email_confirmation, :note, :user_group_id, :library_id, :locale,
        :expired_at, :locked, :required_role_id, :role_id,
        :keyword_list, :auto_generated_password,
        :user_has_role_attributes => [:user_id, :role_id]
      )
    else
      params.require(:user).permit(
        :email, :password, :password_confirmation, :current_password,
        :remember_me, :email_confirmation, :library_id, :locale,
        :keyword_list, :auto_generated_password
      )
    end
  end
end
