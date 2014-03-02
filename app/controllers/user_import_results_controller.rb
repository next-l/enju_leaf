class UserImportResultsController < ApplicationController
  after_action :verify_authorized
  after_action :verify_policy_scoped, :only => :index
  before_action :set_user_import_result, only: [:show, :edit, :update, :destroy]

  # GET /user_import_results
  def index
    authorize UserImportResult
    @user_import_results = policy_scope(UserImportResult).page(params[:page])
  end

  # GET /user_import_results/1
  def show
  end

  # GET /user_import_results/new
  def new
    @user_import_result = UserImportResult.new
  end

  # GET /user_import_results/1/edit
  def edit
  end

  # POST /user_import_results
  def create
    authorize UserImportResult
    @user_import_result = UserImportResult.new(user_import_result_params)

    if @user_import_result.save
      redirect_to @user_import_result, notice: 'User import result was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /user_import_results/1
  def update
    if @user_import_result.update(user_import_result_params)
      redirect_to @user_import_result, notice: 'User import result was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /user_import_results/1
  def destroy
    @user_import_result.destroy
    redirect_to user_import_results_url, notice: 'User import result was successfully destroyed.'
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
