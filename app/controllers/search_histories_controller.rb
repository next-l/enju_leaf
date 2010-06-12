class SearchHistoriesController < ApplicationController
  before_filter :access_denied, :except => [:index, :show, :destroy]
  # index, show以外は外部からは呼び出されないはず
  load_and_authorize_resource

  # GET /search_histories
  # GET /search_histories.xml
  def index
    if params[:mode] == 'not_found'
      if current_user.has_role?('Administrator')
        @search_histories = SearchHistory.not_found.paginate(:page => params[:page], :order => ['created_at DESC'])
      else
        @search_histories = current_user.search_histories.not_found.paginate(:page => params[:page], :order => ['created_at DESC'])
      end
    else
      if current_user.has_role?('Administrator')
        @search_histories = SearchHistory.paginate(:page => params[:page], :order => ['created_at DESC'])
      else
        @search_histories = current_user.search_histories.paginate(:page => params[:page], :order => ['created_at DESC'])
      end
    end

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @search_histories.to_xml }
    end
  end

  # GET /search_histories/1
  # GET /search_histories/1.xml
  def show
    @search_history = SearchHistory.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @search_history.to_xml }
    end
  end

  # GET /search_histories/new
  def new
  #  @search_history = SearchHistory.new
  end

  # GET /search_histories/1;edit
  def edit
  #  @search_history = @user.search_histories.find(params[:id])
  end

  # POST /search_histories
  # POST /search_histories.xml
  def create
  #  if @user
  #    @search_history = @user.search_histories.new(params[:search_history])
  #  else
  #    @search_history = SearchHistory.new(params[:search_history])
  #  end
  #
  #  respond_to do |format|
  #    if @search_history.save
  #      flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.search_history'))
  #      format.html { redirect_to search_history_url(@search_history) }
  #      format.xml  { head :created, :location => search_history_url(@search_history) }
  #    else
  #      format.html { render :action => "new" }
  #      format.xml  { render :xml => @search_history.errors.to_xml }
  #    end
  #  end
  end

  # PUT /search_histories/1
  # PUT /search_histories/1.xml
  def update
  #  @search_history = @user.search_histories.find(params[:id])
  #
  #  respond_to do |format|
  #    if @search_history.update_attributes(params[:search_history])
  #      flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.search_history'))
  #      format.html { redirect_to user_search_history_url(@user, @search_history) }
  #      format.xml  { head :ok }
  #    else
  #      format.html { render :action => "edit" }
  #      format.xml  { render :xml => @search_history.errors.to_xml }
  #    end
  #  end
  end

  # DELETE /search_histories/1
  # DELETE /search_histories/1.xml
  def destroy
    @search_history = SearchHistory.find(params[:id])
    @search_history.destroy

    respond_to do |format|
      #format.html { redirect_to user_search_histories_url(@user.username) }
      format.html { redirect_to search_histories_url }
      format.xml  { head :ok }
    end
  end
end
