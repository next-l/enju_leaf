class ShelfImportFilesController < ApplicationController
  before_action :set_shelf_import_file, only: %i[ show destroy ]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /shelf_import_files or /shelf_import_files.json
  def index
    @shelf_import_files = ShelfImportFile.order('created_at DESC').page(params[:page])
  end

  # GET /shelf_import_files/1 or /shelf_import_files/1.json
  def show
  end

  # GET /shelf_import_files/new
  def new
    @shelf_import_file = ShelfImportFile.new
  end

  # POST /shelf_import_files or /shelf_import_files.json
  def create
    @shelf_import_file = ShelfImportFile.new(shelf_import_file_params)
    @shelf_import_file.user = current_user

    respond_to do |format|
      if @shelf_import_file.save
        format.html { redirect_to shelf_import_file_url(@shelf_import_file), notice: "Shelf import file was successfully created." }
        format.json { render :show, status: :created, location: @shelf_import_file }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @shelf_import_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shelf_import_files/1 or /shelf_import_files/1.json
  def destroy
    @shelf_import_file.destroy

    respond_to do |format|
      format.html { redirect_to shelf_import_files_url, notice: "Shelf import file was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shelf_import_file
      @shelf_import_file = ShelfImportFile.find(params[:id])
      authorize @shelf_import_file
    end

    def check_policy
      authorize ShelfImportFile
    end

    # Only allow a list of trusted parameters through.
    def shelf_import_file_params
      params.fetch(:shelf_import_file, {}).permit(:note)
    end
end
