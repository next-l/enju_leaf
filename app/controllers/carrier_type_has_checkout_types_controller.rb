class CarrierTypeHasCheckoutTypesController < ApplicationController
  load_and_authorize_resource
  before_filter :get_checkout_type
  before_filter :prepare_options, :only => [:new, :edit]

  # GET /carrier_type_has_checkout_types
  # GET /carrier_type_has_checkout_types.xml
  def index
    @carrier_type_has_checkout_types = CarrierTypeHasCheckoutType.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @carrier_type_has_checkout_types }
    end
  end

  # GET /carrier_type_has_checkout_types/1
  # GET /carrier_type_has_checkout_types/1.xml
  def show
    @carrier_type_has_checkout_type = CarrierTypeHasCheckoutType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @carrier_type_has_checkout_type }
    end
  end

  # GET /carrier_type_has_checkout_types/new
  # GET /carrier_type_has_checkout_types/new.xml
  def new
    @carrier_type_has_checkout_type = CarrierTypeHasCheckoutType.new
    @carrier_type_has_checkout_type.carrier_type = @carrier_type
    @carrier_type_has_checkout_type.checkout_type = @checkout_type

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @carrier_type_has_checkout_type }
    end
  end

  # GET /carrier_type_has_checkout_types/1/edit
  def edit
    @carrier_type_has_checkout_type = CarrierTypeHasCheckoutType.find(params[:id])
  end

  # POST /carrier_type_has_checkout_types
  # POST /carrier_type_has_checkout_types.xml
  def create
    @carrier_type_has_checkout_type = CarrierTypeHasCheckoutType.new(params[:carrier_type_has_checkout_type])

    respond_to do |format|
      if @carrier_type_has_checkout_type.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.carrier_type_has_checkout_type'))
        format.html { redirect_to(@carrier_type_has_checkout_type) }
        format.xml  { render :xml => @carrier_type_has_checkout_type, :status => :created, :location => @carrier_type_has_checkout_type }
      else
        prepare_options
        format.html { render :action => "new" }
        format.xml  { render :xml => @carrier_type_has_checkout_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /carrier_type_has_checkout_types/1
  # PUT /carrier_type_has_checkout_types/1.xml
  def update
    @carrier_type_has_checkout_type = CarrierTypeHasCheckoutType.find(params[:id])

    respond_to do |format|
      if @carrier_type_has_checkout_type.update_attributes(params[:carrier_type_has_checkout_type])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.carrier_type_has_checkout_type'))
        format.html { redirect_to(@carrier_type_has_checkout_type) }
        format.xml  { head :ok }
      else
        prepare_options
        format.html { render :action => "edit" }
        format.xml  { render :xml => @carrier_type_has_checkout_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /carrier_type_has_checkout_types/1
  # DELETE /carrier_type_has_checkout_types/1.xml
  def destroy
    @carrier_type_has_checkout_type = CarrierTypeHasCheckoutType.find(params[:id])
    @carrier_type_has_checkout_type.destroy

    respond_to do |format|
      format.html { redirect_to(carrier_type_has_checkout_types_url) }
      format.xml  { head :ok }
    end
  end

  private
  def prepare_options
    @checkout_types = CheckoutType.all
    @carrier_types = CarrierType.all
  end
end
