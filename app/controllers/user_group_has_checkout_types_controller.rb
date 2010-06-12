class UserGroupHasCheckoutTypesController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource
  before_filter :get_user_group
  before_filter :get_checkout_type
  before_filter :prepare_options, :only => [:new, :edit]

  # GET /user_group_has_checkout_types
  # GET /user_group_has_checkout_types.xml
  def index
    @user_group_has_checkout_types = UserGroupHasCheckoutType.all(:include => [:user_group, :checkout_type], :order => ['user_groups.position, checkout_types.position'])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_group_has_checkout_types }
    end
  end

  # GET /user_group_has_checkout_types/1
  # GET /user_group_has_checkout_types/1.xml
  def show
    @user_group_has_checkout_type = UserGroupHasCheckoutType.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_group_has_checkout_type }
    end
  end

  # GET /user_group_has_checkout_types/new
  # GET /user_group_has_checkout_types/new.xml
  def new
    @user_group_has_checkout_type = UserGroupHasCheckoutType.new
    @user_group_has_checkout_type.checkout_type = @checkout_type
    @user_group_has_checkout_type.user_group = @user_group

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_group_has_checkout_type }
    end
  end

  # GET /user_group_has_checkout_types/1/edit
  def edit
    @user_group_has_checkout_type = UserGroupHasCheckoutType.find(params[:id])
  end

  # POST /user_group_has_checkout_types
  # POST /user_group_has_checkout_types.xml
  def create
    @user_group_has_checkout_type = UserGroupHasCheckoutType.new(params[:user_group_has_checkout_type])

    respond_to do |format|
      if @user_group_has_checkout_type.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.user_group_has_checkout_type'))
        format.html { redirect_to(@user_group_has_checkout_type) }
        format.xml  { render :xml => @user_group_has_checkout_type, :status => :created, :location => @user_group_has_checkout_type }
      else
        prepare_options
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_group_has_checkout_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_group_has_checkout_types/1
  # PUT /user_group_has_checkout_types/1.xml
  def update
    @user_group_has_checkout_type = UserGroupHasCheckoutType.find(params[:id])

    respond_to do |format|
      if @user_group_has_checkout_type.update_attributes(params[:user_group_has_checkout_type])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.user_group_has_checkout_type'))
        format.html { redirect_to(@user_group_has_checkout_type) }
        format.xml  { head :ok }
      else
        prepare_options
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_group_has_checkout_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_group_has_checkout_types/1
  # DELETE /user_group_has_checkout_types/1.xml
  def destroy
    @user_group_has_checkout_type = UserGroupHasCheckoutType.find(params[:id])
    @user_group_has_checkout_type.destroy

    respond_to do |format|
      format.html { redirect_to(user_group_has_checkout_types_url) }
      format.xml  { head :ok }
    end
  end

  private
  def prepare_options
    @checkout_types = CheckoutType.all
    @user_groups = UserGroup.all
  end
end
