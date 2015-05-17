# -*- encoding: utf-8 -*-
class ProfilesController < ApplicationController
  before_action :set_profile, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :prepare_options, only: [:new, :edit]

  # GET /profiles
  # GET /profiles.json
  def index
    query = flash[:query] = params[:query].to_s
    @query = query.dup
    @count = {}

    sort = {sort_by: 'created_at', order: 'desc'}
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

    search = Profile.search
    search.build do
      fulltext query if query
      order_by sort[:sort_by], sort[:order]
    end
    search.query.paginate(page.to_i, Profile.default_per_page)
    @profiles = search.execute!.results
    @count[:query_result] = @profiles.total_entries

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @profiles }
    end
  end

  # GET /profiles/1
  # GET /profiles/1.json
  def show
    if @profile.user == current_user
      redirect_to my_account_url
      return
    end

    respond_to do |format|
      format.html # show.html.erb
      format.html.phone
      format.json { render json: @profile }
    end
  end

  # GET /profiles/new
  def new
    @profile = Profile.new
    @profile.user = User.new
    @profile.user_group = current_user.profile.user_group
    @profile.library = current_user.profile.library
    @profile.locale = current_user.profile.locale

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @profile }
    end
  end

  # GET /profiles/1/edit
  def edit
    if @profile.user == current_user
      redirect_to edit_my_account_url
      return
    end
    if @profile.user.try(:locked_at?)
      @profile.user.locked = true
    end
  end

  # POST /profiles
  # POST /profiles.json
  def create
    if current_user.has_role?('Librarian')
      @profile = Profile.new(profile_params)
      if @profile.user
        @profile.user.operator = current_user
      end
    else
      @profile = Profile.new(profile_params)
    end

    respond_to do |format|
      if @profile.save
        if @profile.user
          identity = Identity.new(
            name: @profile.user.username,
            email: @profile.user.email,
          )
          identity.set_auto_generated_password
          identity.save!
          @profile.user.update_attributes!({
            uid: identity.id,
            provider: 'identity'
          })
          @profile.user.role = Role.where(name: 'User').first
          flash[:temporary_password] = password
        end
        format.html { redirect_to @profile, notice: t('controller.successfully_created', model: t('activerecord.models.profile')) }
        format.json { render json: @profile, status: :created, location: @profile }
      else
        prepare_options
        format.html { render action: "new" }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /profiles/1
  # PUT /profiles/1.json
  def update
    @profile.update_attributes(profile_update_params)
    if @profile.user
      if @profile.user.auto_generated_password == "1"
        password = @profile.user.set_auto_generated_password
      end
    end

    respond_to do |format|
      if @profile.save
        flash[:temporary_password] = password
        format.html { redirect_to @profile, notice: t('controller.successfully_updated', model: t('activerecord.models.profile')) }
        format.json { head :no_content }
      else
        prepare_options
        format.html { render action: "edit" }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /profiles/1
  # DELETE /profiles/1.json
  def destroy
    @profile.destroy

    respond_to do |format|
      format.html { redirect_to profiles_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.profile')) }
      format.json { head :no_content }
    end
  end

  private
  def set_profile
    @profile = Profile.find(params[:id])
    authorize @profile
  end

  def check_policy
    authorize Profile
  end

  def profile_params
    attrs = [
      :full_name, :full_name_transcription,
      :keyword_list, :locale,
      :save_checkout_history, :checkout_icalendar_token, # EnjuCirculation
      :save_search_history, # EnjuSearchLog
    ]
    attrs += [
      :library_id, :expired_at, :birth_date,
      :user_group_id, :required_role_id, :note, :locked, :user_number, {
        :user_attributes => [
          :id, :username, :email, :current_password,
          {:user_has_role_attributes => [:id, :role_id]}
        ]
      }
    ] if current_user.has_role?('Librarian')
    params.require(:profile).permit(*attrs)
  end

  def profile_update_params
    attrs = [
      :full_name, :full_name_transcription,
      :keyword_list, :locale,
      :save_checkout_history, # EnjuCirculation
      :save_search_history, # EnjuSearchLog
    ]
    attrs += [
      :library_id, :expired_at, :birth_date,
      :user_group_id, :required_role_id, :note, :locked, :user_number, {
        :user_attributes => [
          :id, :email, :current_password, :auto_generated_password,
          {:user_has_role_attributes => [:id, :role_id]}
        ]
      }
    ] if current_user.has_role?('Librarian')
    params.require(:profile).permit(*attrs)
  end

  def prepare_options
    @user_groups = UserGroup.all
    @roles = Role.all
    @libraries = Library.all
    @languages = Language.all
  end
end
