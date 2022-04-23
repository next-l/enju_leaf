class BookmarkStatsController < ApplicationController
  before_action :set_bookmark_stat, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  after_action :convert_charset, only: :show

  # GET /bookmark_stats
  # GET /bookmark_stats.json
  def index
    @bookmark_stats = BookmarkStat.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /bookmark_stats/1
  # GET /bookmark_stats/1.json
  def show
    if request.format.text?
      per_page = 65534
    else
      per_page = BookmarkStatHasManifestation.default_per_page
    end
    @stats = @bookmark_stat.bookmark_stat_has_manifestations.order('bookmarks_count DESC, manifestation_id').page(params[:page]).per(per_page)

    respond_to do |format|
      format.html # show.html.erb
      format.text
    end
  end

  # GET /bookmark_stats/new
  def new
    @bookmark_stat = BookmarkStat.new
  end

  # GET /bookmark_stats/1/edit
  def edit
  end

  # POST /bookmark_stats
  # POST /bookmark_stats.json
  def create
    @bookmark_stat = BookmarkStat.new(bookmark_stat_params)

    respond_to do |format|
      if @bookmark_stat.save
        format.html { redirect_to @bookmark_stat, notice: t('controller.successfully_created', model: t('activerecord.models.bookmark_stat')) }
        format.json { render json: @bookmark_stat, status: :created, location: @bookmark_stat }
      else
        format.html { render action: "new" }
        format.json { render json: @bookmark_stat.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /bookmark_stats/1
  # PUT /bookmark_stats/1.json
  def update
    respond_to do |format|
      if @bookmark_stat.update(bookmark_stat_params)
        format.html { redirect_to @bookmark_stat, notice: t('controller.successfully_updated', model: t('activerecord.models.bookmark_stat')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @bookmark_stat.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bookmark_stats/1
  # DELETE /bookmark_stats/1.json
  def destroy
    @bookmark_stat.destroy

    respond_to do |format|
      format.html { redirect_to bookmark_stats_url }
      format.json { head :no_content }
    end
  end

  private
  def set_bookmark_stat
    @bookmark_stat = BookmarkStat.find(params[:id])
    authorize @bookmark_stat
  end

  def check_policy
    authorize BookmarkStat
  end

  def bookmark_stat_params
    params.require(:bookmark_stat).permit(:start_date, :end_date, :note)
  end
end
