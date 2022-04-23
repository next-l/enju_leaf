class NewsPostsController < ApplicationController
  before_action :set_news_post, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :prepare_options, only: [:new, :edit]

  # GET /news_posts
  # GET /news_posts.json
  def index
    if current_user.try(:has_role?, 'Librarian')
      @news_posts = NewsPost.page(params[:page])
    else
      @news_posts = NewsPost.published.page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.rss
      format.atom
    end
  end

  # GET /news_posts/1
  # GET /news_posts/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /news_posts/new
  def new
    @news_post = NewsPost.new
  end

  # GET /news_posts/1/edit
  def edit
  end

  # POST /news_posts
  # POST /news_posts.json
  def create
    @news_post = NewsPost.new(news_post_params)
    @news_post.user = current_user

    respond_to do |format|
      if @news_post.save
        format.html { redirect_to(@news_post, notice: t('controller.successfully_created', model: t('activerecord.models.news_post'))) }
        format.json { render json: @news_post, status: :created, location: @news_post }
      else
        prepare_options
        format.html { render action: "new" }
        format.json { render json: @news_post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /news_posts/1
  # PUT /news_posts/1.json
  def update
    if params[:move]
      move_position(@news_post, params[:move])
      return
    end

    respond_to do |format|
      if @news_post.update(news_post_params)
        format.html { redirect_to(@news_post, notice: t('controller.successfully_updated', model: t('activerecord.models.news_post'))) }
        format.json { head :no_content }
      else
        prepare_options
        format.html { render action: "edit" }
        format.json { render json: @news_post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /news_posts/1
  # DELETE /news_posts/1.json
  def destroy
    @news_post.destroy

    respond_to do |format|
      format.html { redirect_to(news_posts_url) }
      format.json { head :no_content }
    end
  end

  private
  def set_news_post
    @news_post = NewsPost.find(params[:id])
    authorize @news_post
  end

  def check_policy
    authorize NewsPost
  end

  def news_post_params
    params.require(:news_post).permit(:title, :body)
  end

  def prepare_options
    @roles = Role.all
  end
end
