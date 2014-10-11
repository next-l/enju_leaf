class ProfilesController < ApplicationController
  before_action :set_profile, only: [:show, :edit, :update, :destroy]
  before_action :prepare_options, only: [:new, :edit]
  after_action :verify_authorized

  # GET /profiles
  # GET /profiles.json
  def index
    @profiles = Profile.page(params[:page])
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

  end

  # GET /profiles/1
  # GET /profiles/1.json
  def show
    if @profile.user == current_user
      redirect_to my_account_url
      return
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
  end

  # POST /profiles
  # POST /profiles.json
  def create
    @profile = Profile.new(profile_params)
    if current_user.has_role?('Librarian')
      if @profile.user
        @profile.user.operator = current_user
        @profile.user.set_auto_generated_password
      end
    end

    respond_to do |format|
      if @profile.save
        if @profile.user
          @profile.user.role = Role.where(name: 'User').first
          flash[:temporary_password] = @profile.user.password
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

  # PATCH/PUT /profiles/1
  # PATCH/PUT /profiles/1.json
  def update
    @profile.update_attributes(profile_params)
    if @profile.user
      if @profile.user.auto_generated_password == "1"
        @profile.user.set_auto_generated_password
        flash[:temporary_password] = @profile.user.password
      end
    end

    respond_to do |format|
      if @profile.save
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
    # Use callbacks to share common setup or constraints between actions.
    def set_profile
      @profile = Profile.find(params[:id])
      authorize @profile
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def profile_params
      params.require(:profile).permit(
        :user_id, :user_group_id, :library_id, :locale, :user_number,
        :full_name, :note, :keyword, :required_role_id
      )
    end

    def prepare_options
      @user_groups = UserGroup.all
      @roles = Role.all
      @libraries = Library.all
      @languages = Language.all
    end
end
