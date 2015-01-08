class UserImportResultsController < ApplicationController
  load_and_authorize_resource

  # GET /user_import_results
  # GET /user_import_results.json
  def index
    @user_import_file = UserImportFile.where(id: params[:user_import_file_id]).first
    if @user_import_file
      @user_import_results = @user_import_file.user_import_results.page(params[:page])
    else
      @user_import_results = UserImportResult.page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_import_results }
      format.txt
    end
  end

  # GET /user_import_results/1
  # GET /user_import_results/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user_import_result }
    end
  end

  # DELETE /user_import_results/1
  # DELETE /user_import_results/1.json
  def destroy
    @user_import_result.destroy

    respond_to do |format|
      format.html { redirect_to user_import_results_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.user_import_result')) }
      format.json { head :no_content }
    end
  end

  private
  def user_import_result_params
    params.require(:user_import_result).permit(
      :user_import_file_id, :user_id, :body
    )
  end
end
