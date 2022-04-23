class CheckoutTypesController < ApplicationController
  before_action :set_checkout_type, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :get_user_group

  # GET /checkout_types
  # GET /checkout_types.json
  def index
    if @user_group
      @checkout_types = @user_group.checkout_types.order('checkout_types.position')
    else
      @checkout_types = CheckoutType.order(:position)
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /checkout_types/1
  # GET /checkout_types/1.json
  def show
    if @user_group
      @checkout_type = @user_group.checkout_types.find(params[:id])
    end

    respond_to do |format|
      format.html # show.html.erb
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
  # POST /checkout_types.json
  def create
    if @user_group
      @checkout_type = @user_group.checkout_types.new(checkout_type_params)
    else
      @checkout_type = CheckoutType.new(checkout_type_params)
    end

    respond_to do |format|
      if @checkout_type.save
        format.html { redirect_to @checkout_type, notice: t('controller.successfully_created', model: t('activerecord.models.checkout_type')) }
        format.json { render json: @checkout_type, status: :created, location: @checkout_type }
      else
        format.html { render action: "new" }
        format.json { render json: @checkout_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /checkout_types/1
  # PUT /checkout_types/1.json
  def update
    if params[:move]
      move_position(@checkout_type, params[:move])
      return
    end

    respond_to do |format|
      if @checkout_type.update(checkout_type_params)
        format.html { redirect_to @checkout_type, notice: t('controller.successfully_updated', model: t('activerecord.models.checkout_type')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @checkout_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /checkout_types/1
  # DELETE /checkout_types/1.json
  def destroy
    if @user_group
      @checkout_type = @user_group.checkout_types.find(params[:id])
    end
    @checkout_type.destroy

    respond_to do |format|
      format.html { redirect_to checkout_types_url }
      format.json { head :no_content }
    end
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
