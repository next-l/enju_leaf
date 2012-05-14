class ReserveStatHasUsersController < ApplicationController
  load_and_authorize_resource

  # GET /reserve_stat_has_users
  # GET /reserve_stat_has_users.json
  def index
    @reserve_stat_has_users = ReserveStatHasUser.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @reserve_stat_has_users }
    end
  end

  # GET /reserve_stat_has_users/1
  # GET /reserve_stat_has_users/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @reserve_stat_has_user }
    end
  end

  # GET /reserve_stat_has_users/new
  # GET /reserve_stat_has_users/new.json
  def new
    @reserve_stat_has_user = ReserveStatHasUser.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @reserve_stat_has_user }
    end
  end

  # GET /reserve_stat_has_users/1/edit
  def edit
  end

  # POST /reserve_stat_has_users
  # POST /reserve_stat_has_users.json
  def create
    @reserve_stat_has_user = ReserveStatHasUser.new(params[:reserve_stat_has_user])

    respond_to do |format|
      if @reserve_stat_has_user.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.reserve_stat_has_user'))
        format.html { redirect_to(@reserve_stat_has_user) }
        format.json { render :json => @reserve_stat_has_user, :status => :created, :location => @reserve_stat_has_user }
      else
        format.html { render :action => "new" }
        format.json { render :json => @reserve_stat_has_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /reserve_stat_has_users/1
  # PUT /reserve_stat_has_users/1.json
  def update
    respond_to do |format|
      if @reserve_stat_has_user.update_attributes(params[:reserve_stat_has_user])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.reserve_stat_has_user'))
        format.html { redirect_to(@reserve_stat_has_user) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @reserve_stat_has_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /reserve_stat_has_users/1
  # DELETE /reserve_stat_has_users/1.json
  def destroy
    @reserve_stat_has_user.destroy

    respond_to do |format|
      format.html { redirect_to(reserve_stat_has_users_url) }
      format.json { head :no_content }
    end
  end
end
