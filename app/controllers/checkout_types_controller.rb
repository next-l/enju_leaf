class CheckoutTypesController < ApplicationController
  add_breadcrumb "I18n.t('page.configuration')", 'page_configuration_path'
  add_breadcrumb "I18n.t('page.listing', :model => I18n.t('activerecord.models.checkout_type'))", 'checkout_types_path'
  add_breadcrumb "I18n.t('page.new', :model => I18n.t('activerecord.models.checkout_type'))", 'new_checkout_type_path', :only => [:new, :create]
  add_breadcrumb "I18n.t('page.editing', :model => I18n.t('activerecord.models.checkout_type'))", 'edit_checkout_type_path(params[:id])', :only => [:edit, :update]
  add_breadcrumb "I18n.t('activerecord.models.checkout_type')", '', :only => [:show]
  load_and_authorize_resource
  before_filter :get_user_group

  # GET /checkout_types
  # GET /checkout_types.json
  def index
    if @user_group
      @checkout_types = @user_group.checkout_types.order('checkout_types.position').page(params[:page])
    else
      @checkout_types = CheckoutType.order(:position).page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @checkout_types }
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
      format.json { render :json => @checkout_type }
    end
  end

  # GET /checkout_types/new
  # GET /checkout_types/new.json
  def new
    if @user_group
      @checkout_type = @user_group.checkout_types.new
    else
      @checkout_type = CheckoutType.new
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @checkout_type }
    end
  end

  # GET /checkout_types/1/edit
  def edit
    if @user_group
      @checkout_type = @user_group.checkout_types.find(params[:id])
    end
  end

  # POST /checkout_types
  # POST /checkout_types.json
  def create
    if @user_group
      @checkout_type = @user_group.checkout_types.new(params[:checkout_type])
    else
      @checkout_type = CheckoutType.new(params[:checkout_type])
    end

    respond_to do |format|
      if @checkout_type.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.checkout_type'))
        format.html { redirect_to(@checkout_type) }
        format.json { render :json => @checkout_type, :status => :created, :location => @checkout_type }
      else
        format.html { render :action => "new" }
        format.json { render :json => @checkout_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /checkout_types/1
  # PUT /checkout_types/1.json
  def update
    if @user_group
      @checkout_type = @user_group.checkout_types.find(params[:id])
    end

    if params[:move]
      move_position(@checkout_type, params[:move])
      return
    end

    respond_to do |format|
      if @checkout_type.update_attributes(params[:checkout_type])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.checkout_type'))
        format.html { redirect_to(@checkout_type) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @checkout_type.errors, :status => :unprocessable_entity }
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
      format.html { redirect_to(checkout_types_url) }
      format.json { head :no_content }
    end
  end
end
