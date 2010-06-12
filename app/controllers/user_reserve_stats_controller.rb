class UserReserveStatsController < ApplicationController
  load_and_authorize_resource
  after_filter :convert_charset, :only => :show

  # GET /user_reserve_stats
  # GET /user_reserve_stats.xml
  def index
    @user_reserve_stats = UserReserveStat.paginate(:all, :page => params[:page], :order => 'id DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_reserve_stats }
    end
  end

  # GET /user_reserve_stats/1
  # GET /user_reserve_stats/1.xml
  def show
    @user_reserve_stat = UserReserveStat.find(params[:id])
    ReserveStatHasUser.per_page = 65534 if params[:format] == 'csv'
    @stats = @user_reserve_stat.reserve_stat_has_users.paginate(:all, :order => 'reserves_count DESC, user_id', :page => params[:page])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_reserve_stat }
      format.csv
    end
  end

  # GET /user_reserve_stats/new
  # GET /user_reserve_stats/new.xml
  def new
    @user_reserve_stat = UserReserveStat.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_reserve_stat }
    end
  end

  # GET /user_reserve_stats/1/edit
  def edit
    @user_reserve_stat = UserReserveStat.find(params[:id])
  end

  # POST /user_reserve_stats
  # POST /user_reserve_stats.xml
  def create
    @user_reserve_stat = UserReserveStat.new(params[:user_reserve_stat])

    respond_to do |format|
      if @user_reserve_stat.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.user_reserve_stat'))
        format.html { redirect_to(@user_reserve_stat) }
        format.xml  { render :xml => @user_reserve_stat, :status => :created, :location => @user_reserve_stat }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_reserve_stat.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_reserve_stats/1
  # PUT /user_reserve_stats/1.xml
  def update
    @user_reserve_stat = UserReserveStat.find(params[:id])

    respond_to do |format|
      if @user_reserve_stat.update_attributes(params[:user_reserve_stat])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.user_reserve_stat'))
        format.html { redirect_to(@user_reserve_stat) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_reserve_stat.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_reserve_stats/1
  # DELETE /user_reserve_stats/1.xml
  def destroy
    @user_reserve_stat = UserReserveStat.find(params[:id])
    @user_reserve_stat.destroy

    respond_to do |format|
      format.html { redirect_to(user_reserve_stats_url) }
      format.xml  { head :ok }
    end
  end
end
