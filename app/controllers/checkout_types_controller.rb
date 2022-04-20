class CheckoutTypesController < ApplicationController
  before_action :set_checkout_type, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :get_user_group

  # GET /checkout_types
  def index
    if @user_group
      @checkout_types = @user_group.checkout_types.order('checkout_types.position')
    else
      @checkout_types = CheckoutType.order(:position)
    end
  end

  # GET /checkout_types/1
  def show
    if @user_group
      @checkout_type = @user_group.checkout_types.find(params[:id])
    end
  end

  # GET /checkout_types/new
  def new
    if @user_group
      @checkout_type = @user_group.checkout_types.new
    else
      @checkout_type = CheckoutType.new
    end
  end

  # GET /checkout_types/1/edit
  def edit
  end

  # POST /checkout_types
  def create
    if @user_group
      @checkout_type = @user_group.checkout_types.new(checkout_type_params)
    else
      @checkout_type = CheckoutType.new(checkout_type_params)
    end

    respond_to do |format|
      if @checkout_type.save
        format.html { redirect_to @checkout_type, notice: t('controller.successfully_created', model: t('activerecord.models.checkout_type')) }
      else
        format.html { render action: "new" }
      end
    end
  end

  # PUT /checkout_types/1
  def update
    if params[:move]
      move_position(@checkout_type, params[:move])
      return
    end

    respond_to do |format|
      if @checkout_type.update(checkout_type_params)
        format.html { redirect_to @checkout_type, notice: t('controller.successfully_updated', model: t('activerecord.models.checkout_type')) }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # DELETE /checkout_types/1
  def destroy
    if @user_group
      @checkout_type = @user_group.checkout_types.find(params[:id])
    end
    @checkout_type.destroy
    redirect_to checkout_types_url
  end

  private

  def set_checkout_type
    @checkout_type = CheckoutType.find(params[:id])
    authorize @checkout_type
  end

  def check_policy
    authorize CheckoutType
  end

  def checkout_type_params
    params.require(:checkout_type).permit(:name, :display_name, :note)
  end
end
