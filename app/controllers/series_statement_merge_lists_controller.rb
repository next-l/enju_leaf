class SeriesStatementMergeListsController < ApplicationController
  before_action :set_series_statement_merge_list, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /series_statement_merge_lists
  # GET /series_statement_merge_lists.json
  def index
    @series_statement_merge_lists = SeriesStatementMergeList.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /series_statement_merge_lists/1
  # GET /series_statement_merge_lists/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /series_statement_merge_lists/new
  def new
    @series_statement_merge_list = SeriesStatementMergeList.new
  end

  # GET /series_statement_merge_lists/1/edit
  def edit
  end

  # POST /series_statement_merge_lists
  # POST /series_statement_merge_lists.json
  def create
    @series_statement_merge_list = SeriesStatementMergeList.new(series_statement_merge_list_params)

    respond_to do |format|
      if @series_statement_merge_list.save
        flash[:notice] = t('controller.successfully_created', model: t('activerecord.models.series_statement_merge_list'))
        format.html { redirect_to(@series_statement_merge_list) }
        format.json { render json: @series_statement_merge_list, status: :created, location: @series_statement_merge_list }
      else
        format.html { render action: "new" }
        format.json { render json: @series_statement_merge_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /series_statement_merge_lists/1
  # PUT /series_statement_merge_lists/1.json
  def update
    respond_to do |format|
      if @series_statement_merge_list.update(series_statement_merge_list_params)
        if params[:mode] == 'merge'
          selected_series_statement = SeriesStatement.find(params[:selected_series_statement_id]) rescue nil
          if selected_series_statement
            flash[:notice] = t('merge_list.successfully_merged', model: t('activerecord.models.series_statement'))
          else
            flash[:notice] = t('merge_list.specify_id', model: t('activerecord.models.series_statement'))
            redirect_to series_statement_merge_list_url(@series_statement_merge_list)
            return
          end
        else
          flash[:notice] = t('controller.successfully_updated', model: t('activerecord.models.series_statement_merge_list'))
        end
        format.html { redirect_to(@series_statement_merge_list) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @series_statement_merge_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /series_statement_merge_lists/1
  # DELETE /series_statement_merge_lists/1.json
  def destroy
    @series_statement_merge_list.destroy

    respond_to do |format|
      format.html { redirect_to(series_statement_merge_lists_url) }
      format.json { head :no_content }
    end
  end

  private

  def set_series_statement_merge_list
    @series_statement_merge_list = SeriesStatementMergeList.find(params[:id])
    authorize @series_statement_merge_list
  end

  def check_policy
    authorize SeriesStatementMergeList
  end

  def series_statement_merge_list_params
    params.require(:series_statement_merge_list).permit(:title)
  end
end
