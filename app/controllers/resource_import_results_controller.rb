class ResourceImportResultsController < ApplicationController
  before_action :set_resource_import_result, only: [:show, :destroy]
  before_action :check_policy, only: [:index]

  # GET /resource_import_results
  # GET /resource_import_results.json
  def index
    @resource_import_file = ResourceImportFile.find_by(id: params[:resource_import_file_id])
    if @resource_import_file
      if request.format.text?
        @resource_import_results = @resource_import_file.resource_import_results
      else
        @resource_import_results = @resource_import_file.resource_import_results.page(params[:page])
      end
    else
      @resource_import_results = ResourceImportResult.page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.text
    end
  end

  # GET /resource_import_results/1
  # GET /resource_import_results/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # DELETE /resource_import_results/1
  # DELETE /resource_import_results/1.json
  def destroy
    @resource_import_result.destroy

    respond_to do |format|
      format.html { redirect_to resource_import_results_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.resource_import_result')) }
      format.json { head :no_content }
    end
  end

  private
  def set_resource_import_result
    @resource_import_result = ResourceImportResult.find(params[:id])
    authorize @resource_import_result
  end

  def check_policy
    authorize ResourceImportResult
  end

  def resource_import_result_params
    params.require(:resource_import_result).permit(
      :resource_import_file_id, :manifestation_id, :item_id, :body
    )
  end
end
