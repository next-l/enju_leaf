class SeriesStatementMergesController < ApplicationController
  before_action :set_series_statement_merge, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :get_series_statement, :get_series_statement_merge_list

  # GET /series_statement_merges
  # GET /series_statement_merges.json
  def index
    if @series_statement
      @series_statement_merges = @series_statement.series_statement_merges.order('series_statement_merges.id').page(params[:page])
    elsif @series_statement_merge_list
      @series_statement_merges = @series_statement_merge_list.series_statement_merges.order('series_statement_merges.id').includes(:series_statement).page(params[:page])
    else
      @series_statement_merges = SeriesStatementMerge.page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /series_statement_merges/1
  # GET /series_statement_merges/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /series_statement_merges/new
  def new
    @series_statement_merge = SeriesStatementMerge.new
    @series_statement_merge.series_statement = @series_statement
    @series_statement_merge.series_statement_merge_list = @series_statement_merge_list
  end

  # GET /series_statement_merges/1/edit
  def edit
  end

  # POST /series_statement_merges
  # POST /series_statement_merges.json
  def create
    @series_statement_merge = SeriesStatementMerge.new(series_statement_merge_params)

    respond_to do |format|
      if @series_statement_merge.save
        flash[:notice] = t('controller.successfully_created', model: t('activerecord.models.series_statement_merge'))
        format.html { redirect_to(@series_statement_merge) }
        format.json { render json: @series_statement_merge, status: :created, location: @series_statement_merge }
      else
        format.html { render action: "new" }
        format.json { render json: @series_statement_merge.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /series_statement_merges/1
  # PUT /series_statement_merges/1.json
  def update
    respond_to do |format|
      if @series_statement_merge.update(series_statement_merge_params)
        flash[:notice] = t('controller.successfully_updated', model: t('activerecord.models.series_statement_merge'))
        format.html { redirect_to(@series_statement_merge) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @series_statement_merge.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /series_statement_merges/1
  # DELETE /series_statement_merges/1.json
  def destroy
    @series_statement_merge.destroy

    respond_to do |format|
      format.html { redirect_to(series_statement_merges_url) }
      format.json { head :no_content }
    end
  end

  private

  def set_series_statement_merge
    @series_statement_merge = SeriesStatementMerge.find(params[:id])
    authorize @series_statement_merge
  end

  def check_policy
    authorize SeriesStatementMerge
  end

  def series_statement_merge_params
    params.require(:series_statement_merge).permit(
      :series_statement_id, :series_statement_merge_list_id
    )
  end
end
