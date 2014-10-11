class UserImportResultsController < ApplicationController
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index
  before_action :set_user_import_result, only: [:show, :edit, :update, :destroy]

  # GET /user_import_results
  def index
    authorize UserImportResult
    @user_import_file = UserImportFile.where(id: params[:user_import_file_id]).first
    if @user_import_file
      @user_import_results = @user_import_file.user_import_results.page(params[:page])
    else
      @user_import_results = UserImportResult.page(params[:page])
    end
  end

  # GET /user_import_results/1
  def show
  end

  # DELETE /user_import_results/1
  def destroy
    @user_import_result.destroy
    redirect_to user_import_results_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.user_import_result'))
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_import_result
      @user_import_result = UserImportResult.find(params[:id])
      authorize @user_import_result
    end

    # Only allow a trusted parameter "white list" through.
    def user_import_result_params
      params.require(:user_import_result).permit(:user_import_file_id, :user_id, :body)
    end
end
