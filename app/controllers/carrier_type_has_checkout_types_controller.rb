class CarrierTypeHasCheckoutTypesController < ApplicationController
  add_breadcrumb "I18n.t('page.configuration')", 'page_configuration_path'
  add_breadcrumb "I18n.t('page.listing', :model => I18n.t('activerecord.models.carrier_type_has_checkout_type'))", 'carrier_type_has_checkout_types_path'
  add_breadcrumb "I18n.t('page.new', :model => I18n.t('activerecord.models.carrier_type_has_checkout_type'))", 'new_carrier_type_has_checkout_type_path', :only => [:new, :create]
  add_breadcrumb "I18n.t('page.editing', :model => I18n.t('activerecord.models.carrier_type_has_checkout_type'))", 'edit_carrier_type_has_checkout_type_path(params[:id])', :only => [:edit, :update]
  add_breadcrumb "I18n.t('activerecord.models.carrier_type_has_checkout_type')", 'carrier_type_has_checkout_type_path(params[:id])', :only => [:show]
  load_and_authorize_resource
  before_filter :get_checkout_type
  before_filter :prepare_options, :only => [:new, :edit]

  # GET /carrier_type_has_checkout_types
  # GET /carrier_type_has_checkout_types.json
  def index
    @carrier_type_has_checkout_types = CarrierTypeHasCheckoutType.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @carrier_type_has_checkout_types }
    end
  end

  # GET /carrier_type_has_checkout_types/1
  # GET /carrier_type_has_checkout_types/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @carrier_type_has_checkout_type }
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
      format.json { render :json => @carrier_type_has_checkout_type }
    end
  end

  # GET /carrier_type_has_checkout_types/1/edit
  def edit
  end

  # POST /carrier_type_has_checkout_types
  # POST /carrier_type_has_checkout_types.json
  def create
    @carrier_type_has_checkout_type = CarrierTypeHasCheckoutType.new(params[:carrier_type_has_checkout_type])

    respond_to do |format|
      if @carrier_type_has_checkout_type.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.carrier_type_has_checkout_type'))
        format.html { redirect_to(@carrier_type_has_checkout_type) }
        format.json { render :json => @carrier_type_has_checkout_type, :status => :created, :location => @carrier_type_has_checkout_type }
      else
        prepare_options
        format.html { render :action => "new" }
        format.json { render :json => @carrier_type_has_checkout_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /carrier_type_has_checkout_types/1
  # PUT /carrier_type_has_checkout_types/1.json
  def update
    respond_to do |format|
      if @carrier_type_has_checkout_type.update_attributes(params[:carrier_type_has_checkout_type])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.carrier_type_has_checkout_type'))
        format.html { redirect_to(@carrier_type_has_checkout_type) }
        format.json { head :no_content }
      else
        prepare_options
        format.html { render :action => "edit" }
        format.json { render :json => @carrier_type_has_checkout_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /carrier_type_has_checkout_types/1
  # DELETE /carrier_type_has_checkout_types/1.json
  def destroy
    @carrier_type_has_checkout_type.destroy

    respond_to do |format|
      format.html { redirect_to(carrier_type_has_checkout_types_url) }
      format.json { head :no_content }
    end
  end

  private
  def prepare_options
    @checkout_types = CheckoutType.all
    @carrier_types = CarrierType.all
  end
end
