class CheckoutTypesController < ApplicationController
  load_and_authorize_resource
  before_filter :get_user_group

  # GET /checkout_types
  # GET /checkout_types.xml
  def index
    if @user_group
      @checkout_types = @user_group.checkout_types.paginate(:all, :page => params[:page], :order => ['checkout_types.position'])
    else
      @checkout_types = CheckoutType.paginate(:all, :page => params[:page], :order => :position)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @checkout_types }
    end
  end

  # GET /checkout_types/1
  # GET /checkout_types/1.xml
  def show
    if @user_group
      @checkout_type = @user_group.checkout_types.find(params[:id])
    else
      @checkout_type = CheckoutType.find(params[:id])
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @checkout_type }
    end
  end

  # GET /checkout_types/new
  # GET /checkout_types/new.xml
  def new
    if @user_group
      @checkout_type = @user_group.checkout_types.new
    else
      @checkout_type = CheckoutType.new
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @checkout_type }
    end
  end

  # GET /checkout_types/1/edit
  def edit
    if @user_group
      @checkout_type = @user_group.checkout_types.find(params[:id])
    else
      @checkout_type = CheckoutType.find(params[:id])
    end
  end

  # POST /checkout_types
  # POST /checkout_types.xml
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
        format.xml  { render :xml => @checkout_type, :status => :created, :location => @checkout_type }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @checkout_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /checkout_types/1
  # PUT /checkout_types/1.xml
  def update
    if @user_group
      @checkout_type = @user_group.checkout_types.find(params[:id])
    else
      @checkout_type = CheckoutType.find(params[:id])
    end

    if params[:position]
      @checkout_type.insert_at(params[:position])
      redirect_to checkout_types_url
      return
    end

    respond_to do |format|
      if @checkout_type.update_attributes(params[:checkout_type])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.checkout_type'))
        format.html { redirect_to(@checkout_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @checkout_type.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /checkout_types/1
  # DELETE /checkout_types/1.xml
  def destroy
    if @user_group
      @checkout_type = @user_group.checkout_types.find(params[:id])
    else
      @checkout_type = CheckoutType.find(params[:id])
    end
    @checkout_type.destroy

    respond_to do |format|
      format.html { redirect_to(checkout_types_url) }
      format.xml  { head :ok }
    end
  end
end
