class UserGroupHasCheckoutTypesController < ApplicationController
  include EnjuCirculation::Controller
  before_action :set_user_group_has_checkout_type, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  helper_method :get_user_group, :get_checkout_type
  before_action :prepare_options, only: [:new, :edit]

  # GET /user_group_has_checkout_types
  def index
    @user_group_has_checkout_types = UserGroupHasCheckoutType.includes([:user_group, :checkout_type]).order('user_groups.position, checkout_types.position').page(params[:page])
  end

  # GET /user_group_has_checkout_types/1
  def show
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
  def create
    @user_group_has_checkout_type = UserGroupHasCheckoutType.new(user_group_has_checkout_type_params)

    respond_to do |format|
      if @user_group_has_checkout_type.save
        format.html { redirect_to(@user_group_has_checkout_type, notice: t('controller.successfully_created', model: t('activerecord.models.user_group_has_checkout_type'))) }
      else
        prepare_options
        format.html { render action: "new" }
      end
    end
  end

  # PUT /user_group_has_checkout_types/1
  def update
    respond_to do |format|
      if @user_group_has_checkout_type.update(user_group_has_checkout_type_params)
        format.html { redirect_to @user_group_has_checkout_type, notice: t('controller.successfully_updated', model: t('activerecord.models.user_group_has_checkout_type')) }
      else
        prepare_options
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /user_group_has_checkout_types/1
  def destroy
    @user_group_has_checkout_type.destroy
    redirect_to user_group_has_checkout_types_url
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
