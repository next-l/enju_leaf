# == Schema Information
#
# Table name: user_import_results
#
#  id                  :integer          not null, primary key
#  user_import_file_id :integer
#  user_id             :integer
#  body                :text
#  created_at          :datetime
#  updated_at          :datetime
#  error_message       :text
#

class UserImportResultsController < ApplicationController
  before_action :set_user_import_result, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /user_import_results
  # GET /user_import_results.json
  def index
    @user_import_file = UserImportFile.where(id: params[:user_import_file_id]).first
    if @user_import_file
      @user_import_results = @user_import_file.user_import_results.order(id: :desc).page(params[:page])
    else
      @user_import_results = UserImportResult.order(id: :desc).page(params[:page])
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
  def set_user_import_result
    @user_import_result = UserImportResult.find(params[:id])
    authorize @user_import_result
  end

  def check_policy
    authorize UserImportResult
  end

  def user_import_result_params
    params.require(:user_import_result).permit(
      :user_import_file_id, :user_id, :body
    )
  end
end
