class AgentImportFilesController < ApplicationController
  before_action :set_agent_import_file, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /agent_import_files
  # GET /agent_import_files.json
  def index
    @agent_import_files = AgentImportFile.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /agent_import_files/1
  # GET /agent_import_files/1.json
  def show
    if @agent_import_file.agent_import.path
      unless ENV['ENJU_STORAGE'] == 's3'
        file = File.expand_path(@agent_import_file.agent_import.path)
      end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.download {
        if ENV['ENJU_STORAGE'] == 's3'
          redirect_to URI.parse(@agent_import_file.agent_import.expiring_url(10)).to_s
        else
          send_file file, filename: @agent_import_file.agent_import_file_name, type: 'application/octet-stream'
        end
      }
    end
  end

  # GET /agent_import_files/new
  def new
    @agent_import_file = AgentImportFile.new
  end

  # GET /agent_import_files/1/edit
  def edit
  end

  # POST /agent_import_files
  # POST /agent_import_files.json
  def create
    @agent_import_file = AgentImportFile.new(agent_import_file_params)
    @agent_import_file.user = current_user

    respond_to do |format|
      if @agent_import_file.save
        if @agent_import_file.mode == 'import'
          AgentImportFileJob.perform_later(@agent_import_file)
        end
        format.html { redirect_to @agent_import_file, notice: t('controller.successfully_created', model: t('activerecord.models.agent_import_file')) }
        format.json { render json: @agent_import_file, status: :created, location: @agent_import_file }
      else
        format.html { render action: "new" }
        format.json { render json: @agent_import_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /agent_import_files/1
  # PUT /agent_import_files/1.json
  def update
    respond_to do |format|
      if @agent_import_file.update(agent_import_file_params)
        if @agent_import_file.mode == 'import'
          AgentImportFileJob.perform_later(@agent_import_file)
        end
        format.html { redirect_to @agent_import_file, notice: t('controller.successfully_updated', model: t('activerecord.models.agent_import_file')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @agent_import_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /agent_import_files/1
  # DELETE /agent_import_files/1.json
  def destroy
    @agent_import_file.destroy

    respond_to do |format|
      format.html { redirect_to agent_import_files_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.agent_import_file')) }
      format.json { head :no_content }
    end
  end

  private
  def set_agent_import_file
    @agent_import_file = AgentImportFile.find(params[:id])
    authorize @agent_import_file
  end

  def check_policy
    authorize AgentImportFile
  end

  def agent_import_file_params
    params.require(:agent_import_file).permit(
      :agent_import, :edit_mode, :user_encoding, :mode
    )
  end
end
