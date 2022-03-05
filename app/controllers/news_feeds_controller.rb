class NewsFeedsController < ApplicationController
  before_action :set_news_feed, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /news_feeds
  # GET /news_feeds.json
  def index
    @news_feeds = NewsFeed.page(params[:page])
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @news_feeds }
    end
  end

  # GET /news_feeds/1
  # GET /news_feeds/1.json
  def show
    if params[:mode] == 'force_reload'
      @news_feed.force_reload
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @news_feed }
    end
  end

  # GET /news_feeds/new
  # GET /news_feeds/new.json
  def new
    @news_feed = NewsFeed.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @news_feed }
    end
  end

  # GET /news_feeds/1/edit
  def edit
  end

  # POST /news_feeds
  # POST /news_feeds.json
  def create
    @news_feed = NewsFeed.new(news_feed_params)

    respond_to do |format|
      if @news_feed.save
        flash[:notice] = t('controller.successfully_created', model: t('activerecord.models.news_feed'))
        format.html { redirect_to(@news_feed) }
        format.json { render json: @news_feed, status: :created, location: @news_feed }
      else
        format.html { render action: "new" }
        format.json { render json: @news_feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /news_feeds/1
  # PUT /news_feeds/1.json
  def update
    if params[:move]
      move_position(@news_feed, params[:move])
      return
    end
    if params[:mode] == 'force_reload'
      expire_cache
    end

    respond_to do |format|
      if @news_feed.update(news_feed_params)
        flash[:notice] = t('controller.successfully_updated', model: t('activerecord.models.news_feed'))
        format.html { redirect_to(@news_feed) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @news_feed.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /news_feeds/1
  # DELETE /news_feeds/1.json
  def destroy
    @news_feed.destroy

    respond_to do |format|
      format.html { redirect_to news_feeds_url }
      format.json { head :no_content }
    end
  end

  private
  def set_news_feed
    @news_feed = NewsFeed.find(params[:id])
    authorize @news_feed
  end

  def check_policy
    authorize NewsFeed
  end

  def news_feed_params
    params.require(:news_feed).permit(:title, :url)
  end

  def expire_cache
    @news_feed.force_reload
  end
end
