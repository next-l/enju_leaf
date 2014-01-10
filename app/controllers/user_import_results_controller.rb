class UserImportResultsController < ApplicationController
  before_filter :set_user_import_result, only: [:show, :edit, :update, :destroy]

  # GET /user_import_results
  def index
    @user_import_results = UserImportResult.all
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
    end

    # Only allow a trusted parameter "white list" through.
    def user_import_result_params
      params.require(:user_import_result).permit(:user_import_file_id, :user_id, :body)
    end
end
