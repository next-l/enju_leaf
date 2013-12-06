class UserGroupHasCheckoutTypesController < ApplicationController
  add_breadcrumb "I18n.t('page.configuration')", 'page_configuration_path'
  add_breadcrumb "I18n.t('page.listing', :model => I18n.t('activerecord.models.user_group_has_checkout_type'))", 'user_group_has_checkout_types_path'
  add_breadcrumb "I18n.t('page.new', :model => I18n.t('activerecord.models.user_group_has_checkout_type'))", 'new_user_group_has_checkout_type_path', :only => [:new, :create]
  add_breadcrumb "I18n.t('page.editing', :model => I18n.t('activerecord.models.user_group_has_checkout_type'))", 'edit_user_group_has_checkout_type_path(params[:id])', :only => [:edit, :update]
  add_breadcrumb "I18n.t('activerecord.models.user_group_has_checkout_type')", 'user_group_has_checkout_type_path(params[:id])', :only => [:show]
  before_filter :check_client_ip_address
  load_and_authorize_resource
  helper_method :get_user_group, :get_checkout_type
  before_filter :prepare_options, :only => [:new, :edit]

  # GET /user_group_has_checkout_types
  # GET /user_group_has_checkout_types.json
  def index
    @user_group_has_checkout_types = UserGroupHasCheckoutType.includes([:user_group, :checkout_type]).order('user_groups.position, checkout_types.position').page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @user_group_has_checkout_types }
    end
  end

  # GET /user_group_has_checkout_types/1
  # GET /user_group_has_checkout_types/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @user_group_has_checkout_type }
    end
  end

  # GET /user_group_has_checkout_types/new
  # GET /user_group_has_checkout_types/new.json
  def new
    @user_group_has_checkout_type = UserGroupHasCheckoutType.new(
      :checkout_type => get_checkout_type,
      :user_group => get_user_group
    )

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @user_group_has_checkout_type }
    end
  end

  # GET /user_group_has_checkout_types/1/edit
  def edit
  end

  # POST /user_group_has_checkout_types
  # POST /user_group_has_checkout_types.json
  def create
    @user_group_has_checkout_type = UserGroupHasCheckoutType.new(params[:user_group_has_checkout_type])

    respond_to do |format|
      if @user_group_has_checkout_type.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.user_group_has_checkout_type'))
        format.html { redirect_to(@user_group_has_checkout_type) }
        format.json { render :json => @user_group_has_checkout_type, :status => :created, :location => @user_group_has_checkout_type }
      else
        prepare_options
        format.html { render :action => "new" }
        format.json { render :json => @user_group_has_checkout_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_group_has_checkout_types/1
  # PUT /user_group_has_checkout_types/1.json
  def update
    respond_to do |format|
      if @user_group_has_checkout_type.update_attributes(params[:user_group_has_checkout_type])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.user_group_has_checkout_type'))
        format.html { redirect_to(@user_group_has_checkout_type) }
        format.json { head :no_content }
      else
        prepare_options
        format.html { render :action => "edit" }
        format.json { render :json => @user_group_has_checkout_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_group_has_checkout_types/1
  # DELETE /user_group_has_checkout_types/1.json
  def destroy
    @user_group_has_checkout_type.destroy

    respond_to do |format|
      format.html { redirect_to(user_group_has_checkout_types_url) }
      format.json { head :no_content }
    end
  end

  private
  def prepare_options
    @checkout_types = CheckoutType.all
    @user_groups = UserGroup.all
  end
end
