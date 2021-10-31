class CarrierTypeHasCheckoutTypesController < ApplicationController
  include EnjuCirculation::Controller
  before_action :set_carrier_type_has_checkout_type, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :get_checkout_type
  before_action :prepare_options, only: [:new, :edit]

  # GET /carrier_type_has_checkout_types
  # GET /carrier_type_has_checkout_types.json
  def index
    @carrier_type_has_checkout_types = CarrierTypeHasCheckoutType.includes([:carrier_type, :checkout_type]).order('carrier_types.position, checkout_types.position').page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @carrier_type_has_checkout_types }
    end
  end

  # GET /carrier_type_has_checkout_types/1
  # GET /carrier_type_has_checkout_types/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @carrier_type_has_checkout_type }
    end
  end

  # GET /carrier_type_has_checkout_types/new
  # GET /carrier_type_has_checkout_types/new.json
  def new
    @carrier_type_has_checkout_type = CarrierTypeHasCheckoutType.new
    @carrier_type_has_checkout_type.carrier_type = @carrier_type
    @carrier_type_has_checkout_type.checkout_type = @checkout_type

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @carrier_type_has_checkout_type }
    end
  end

  # GET /carrier_type_has_checkout_types/1/edit
  def edit
  end

  # POST /carrier_type_has_checkout_types
  # POST /carrier_type_has_checkout_types.json
  def create
    @carrier_type_has_checkout_type = CarrierTypeHasCheckoutType.new(carrier_type_has_checkout_type_params)

    respond_to do |format|
      if @carrier_type_has_checkout_type.save
        flash[:notice] = t('controller.successfully_created', model: t('activerecord.models.carrier_type_has_checkout_type'))
        format.html { redirect_to @carrier_type_has_checkout_type }
        format.json { render json: @carrier_type_has_checkout_type, status: :created, location: @carrier_type_has_checkout_type }
      else
        prepare_options
        format.html { render action: "new" }
        format.json { render json: @carrier_type_has_checkout_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /carrier_type_has_checkout_types/1
  # PUT /carrier_type_has_checkout_types/1.json
  def update
    respond_to do |format|
      if @carrier_type_has_checkout_type.update(carrier_type_has_checkout_type_params)
        flash[:notice] = t('controller.successfully_updated', model: t('activerecord.models.carrier_type_has_checkout_type'))
        format.html { redirect_to @carrier_type_has_checkout_type }
        format.json { head :no_content }
      else
        prepare_options
        format.html { render action: "edit" }
        format.json { render json: @carrier_type_has_checkout_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /carrier_type_has_checkout_types/1
  # DELETE /carrier_type_has_checkout_types/1.json
  def destroy
    @carrier_type_has_checkout_type.destroy

    respond_to do |format|
      format.html { redirect_to carrier_type_has_checkout_types_url }
      format.json { head :no_content }
    end
  end

  private

  def set_carrier_type_has_checkout_type
    @carrier_type_has_checkout_type = CarrierTypeHasCheckoutType.find(params[:id])
    authorize @carrier_type_has_checkout_type
  end

  def check_policy
    authorize CarrierTypeHasCheckoutType
  end

  def carrier_type_has_checkout_type_params
    params.require(:carrier_type_has_checkout_type).permit(
      :carrier_type_id, :checkout_type_id, :note
    )
  end

  def prepare_options
    @checkout_types = CheckoutType.order(:position)
    @carrier_types = CarrierType.order(:position)
  end
end
