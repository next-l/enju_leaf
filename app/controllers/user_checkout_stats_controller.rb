class UserCheckoutStatsController < ApplicationController
  load_and_authorize_resource
  after_filter :convert_charset, :only => :show

  # GET /user_checkout_stats
  # GET /user_checkout_stats.xml
  def index
    @user_checkout_stats = UserCheckoutStat.paginate(:all, :page => params[:page], :order => 'id DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @user_checkout_stats }
    end
  end

  # GET /user_checkout_stats/1
  # GET /user_checkout_stats/1.xml
  def show
    @user_checkout_stat = UserCheckoutStat.find(params[:id])
    CheckoutStatHasUser.per_page = 65534 if params[:format] == 'csv'
    @stats = @user_checkout_stat.checkout_stat_has_users.paginate(:all, :order => 'checkouts_count DESC, user_id', :page => params[:page])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user_checkout_stat }
      format.csv
    end
  end

  # GET /user_checkout_stats/new
  # GET /user_checkout_stats/new.xml
  def new
    @user_checkout_stat = UserCheckoutStat.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user_checkout_stat }
    end
  end

  # GET /user_checkout_stats/1/edit
  def edit
    @user_checkout_stat = UserCheckoutStat.find(params[:id])
  end

  # POST /user_checkout_stats
  # POST /user_checkout_stats.xml
  def create
    @user_checkout_stat = UserCheckoutStat.new(params[:user_checkout_stat])

    respond_to do |format|
      if @user_checkout_stat.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.user_checkout_stat'))
        format.html { redirect_to(@user_checkout_stat) }
        format.xml  { render :xml => @user_checkout_stat, :status => :created, :location => @user_checkout_stat }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user_checkout_stat.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /user_checkout_stats/1
  # PUT /user_checkout_stats/1.xml
  def update
    @user_checkout_stat = UserCheckoutStat.find(params[:id])

    respond_to do |format|
      if @user_checkout_stat.update_attributes(params[:user_checkout_stat])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.user_checkout_stat'))
        format.html { redirect_to(@user_checkout_stat) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user_checkout_stat.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /user_checkout_stats/1
  # DELETE /user_checkout_stats/1.xml
  def destroy
    @user_checkout_stat = UserCheckoutStat.find(params[:id])
    @user_checkout_stat.destroy

    respond_to do |format|
      format.html { redirect_to(user_checkout_stats_url) }
      format.xml  { head :ok }
    end
  end
end
