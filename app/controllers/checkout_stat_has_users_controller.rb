class CheckoutStatHasUsersController < ApplicationController
  load_and_authorize_resource

  # GET /checkout_stat_has_users
  # GET /checkout_stat_has_users.json
  def index
    @checkout_stat_has_users = CheckoutStatHasUser.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @checkout_stat_has_users }
    end
  end

  # GET /checkout_stat_has_users/1
  # GET /checkout_stat_has_users/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @checkout_stat_has_user }
    end
  end

  # GET /checkout_stat_has_users/new
  # GET /checkout_stat_has_users/new.json
  def new
    @checkout_stat_has_user = CheckoutStatHasUser.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @checkout_stat_has_user }
    end
  end

  # GET /checkout_stat_has_users/1/edit
  def edit
  end

  # POST /checkout_stat_has_users
  # POST /checkout_stat_has_users.json
  def create
    @checkout_stat_has_user = CheckoutStatHasUser.new(params[:checkout_stat_has_user])

    respond_to do |format|
      if @checkout_stat_has_user.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.checkout_stat_has_user'))
        format.html { redirect_to(@checkout_stat_has_user) }
        format.json { render :json => @checkout_stat_has_user, :status => :created, :location => @checkout_stat_has_user }
      else
        format.html { render :action => "new" }
        format.json { render :json => @checkout_stat_has_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /checkout_stat_has_users/1
  # PUT /checkout_stat_has_users/1.json
  def update
    respond_to do |format|
      if @checkout_stat_has_user.update_attributes(params[:checkout_stat_has_user])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.checkout_stat_has_user'))
        format.html { redirect_to(@checkout_stat_has_user) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @checkout_stat_has_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /checkout_stat_has_users/1
  # DELETE /checkout_stat_has_users/1.json
  def destroy
    @checkout_stat_has_user.destroy

    respond_to do |format|
      format.html { redirect_to(checkout_stat_has_users_url) }
      format.json { head :no_content }
    end
  end
end
