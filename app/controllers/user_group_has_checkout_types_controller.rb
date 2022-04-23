class UserGroupHasCheckoutTypesController < ApplicationController
  include EnjuCirculation::Controller
  before_action :set_user_group_has_checkout_type, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  helper_method :get_user_group, :get_checkout_type
  before_action :prepare_options, only: [:new, :edit]

  # GET /user_group_has_checkout_types
  # GET /user_group_has_checkout_types.json
  def index
    @user_group_has_checkout_types = UserGroupHasCheckoutType.includes([:user_group, :checkout_type]).order('user_groups.position, checkout_types.position').page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /user_group_has_checkout_types/1
  # GET /user_group_has_checkout_types/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /user_group_has_checkout_types/new
  def new
    @user_group_has_checkout_type = UserGroupHasCheckoutType.new(
      checkout_type: get_checkout_type,
      user_group: get_user_group
    )
  end

  # GET /user_group_has_checkout_types/1/edit
  def edit
  end

  # POST /user_group_has_checkout_types
  # POST /user_group_has_checkout_types.json
  def create
    @user_group_has_checkout_type = UserGroupHasCheckoutType.new(user_group_has_checkout_type_params)

    respond_to do |format|
      if @user_group_has_checkout_type.save
        format.html { redirect_to(@user_group_has_checkout_type, notice: t('controller.successfully_created', model: t('activerecord.models.user_group_has_checkout_type'))) }
        format.json { render json: @user_group_has_checkout_type, status: :created, location: @user_group_has_checkout_type }
      else
        prepare_options
        format.html { render action: "new" }
        format.json { render json: @user_group_has_checkout_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /user_group_has_checkout_types/1
  # PUT /user_group_has_checkout_types/1.json
  def update
    respond_to do |format|
      if @user_group_has_checkout_type.update(user_group_has_checkout_type_params)
        format.html { redirect_to @user_group_has_checkout_type, notice: t('controller.successfully_updated', model: t('activerecord.models.user_group_has_checkout_type')) }
        format.json { head :no_content }
      else
        prepare_options
        format.html { render action: "edit" }
        format.json { render json: @user_group_has_checkout_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_group_has_checkout_types/1
  # DELETE /user_group_has_checkout_types/1.json
  def destroy
    @user_group_has_checkout_type.destroy

    respond_to do |format|
      format.html { redirect_to user_group_has_checkout_types_url }
      format.json { head :no_content }
    end
  end

  private

  def set_user_group_has_checkout_type
    @user_group_has_checkout_type = UserGroupHasCheckoutType.find(params[:id])
    authorize @user_group_has_checkout_type
  end

  def check_policy
    authorize UserGroupHasCheckoutType
  end

  def user_group_has_checkout_type_params
    params.require(:user_group_has_checkout_type).permit(
      :user_group_id, :checkout_type_id,
      :checkout_limit, :checkout_period, :checkout_renewal_limit,
      :reservation_limit, :reservation_expired_period,
      :set_due_date_before_closing_day, :fixed_due_date, :note, :position,
      :user_group, :checkout_type
    )
  end

  def prepare_options
    @checkout_types = CheckoutType.all
    @user_groups = UserGroup.all
  end
end
