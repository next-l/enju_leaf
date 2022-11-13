class PictureFilesController < ApplicationController
  before_action :set_picture_file, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]
  before_action :get_attachable, only: [:index, :new]
  skip_before_action :store_current_location, only: :show

  # GET /picture_files
  # GET /picture_files.json
  def index
    if @attachable
      @picture_files = @attachable.picture_files.attached.page(params[:page])
    else
      @picture_files = PictureFile.attached.page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /picture_files/1
  # GET /picture_files/1.json
  def show
    case params[:size]
    when 'original'
      size = 'original'
    when 'thumb'
      size = 'thumb'
    else
      size = 'medium'
    end

    respond_to do |format|
      format.html # show.html.erb
      format.html.phone
    end
  end

  # GET /picture_files/new
  def new
    unless @attachable
      redirect_to picture_files_url
      return
    end
    #raise unless @event or @manifestation or @shelf or @agent
    @picture_file = PictureFile.new
    @picture_file.picture_attachable = @attachable
  end

  # GET /picture_files/1/edit
  def edit
  end

  # POST /picture_files
  # POST /picture_files.json
  def create
    @picture_file = PictureFile.new(picture_file_params)

    respond_to do |format|
      if @picture_file.save
        format.html { redirect_to @picture_file, notice: t('controller.successfully_created', model: t('activerecord.models.picture_file')) }
        format.json { render json: @picture_file, status: :created, location: @picture_file }
      else
        format.html { render action: "new" }
        format.json { render json: @picture_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /picture_files/1
  # PUT /picture_files/1.json
  def update
    # 並べ替え
    if params[:move]
      move_position(@picture_file, params[:move], false)
      case
      when @picture_file.picture_attachable.is_a?(Shelf)
        redirect_to picture_files_url(shelf_id: @picture_file.picture_attachable_id)
      when @picture_file.picture_attachable.is_a?(Manifestation)
        redirect_to picture_files_url(manifestation_id: @picture_file.picture_attachable_id)
      else
        if defined?(EnjuEvent)
          if @picture_file.picture_attachable.is_a?(Event)
            redirect_to picture_files_url(manifestation_id: @picture_file.picture_attachable_id)
          else
            redirect_to picture_files_url
          end
        else
          redirect_to picture_files_url
        end
      end
      return
    end

    respond_to do |format|
      if @picture_file.update(picture_file_params)
        format.html { redirect_to @picture_file, notice: t('controller.successfully_updated', model: t('activerecord.models.picture_file')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @picture_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /picture_files/1
  # DELETE /picture_files/1.json
  def destroy
    attachable = @picture_file.picture_attachable
    @picture_file.destroy

    respond_to do |format|
      flash[:notice] = t('controller.successfully_deleted', model: t('activerecord.models.picture_file'))
      format.html {
        case attachable.class.name
        when 'Manifestation'
          redirect_to picture_files_url(manifestation_id: attachable.id)
        when 'Agent'
          redirect_to picture_files_url(agent_id: attachable.id)
        when 'Shelf'
          redirect_to picture_files_url(shelf_id: attachable.id)
        else
          if defined?(EnjuEvent)
            if attachable.class.name == 'Event'
              redirect_to picture_files_url(event_id: attachable.id)
            else
              redirect_to picture_files_url
            end
          else
            redirect_to picture_files_url
          end
        end
      }
      format.json { head :no_content }
    end
  end

  private
  def set_picture_file
    @picture_file = PictureFile.find(params[:id])
    authorize @picture_file
  end

  def check_policy
    authorize PictureFile
  end

  def picture_file_params
    params.require(:picture_file).permit(
      :attachment, :picture_attachable_id, :picture_attachable_type
    )
  end

  def get_attachable
    get_manifestation
    if @manifestation
      @attachable = @manifestation
      return
    end
    get_agent
    if @agent
      @attachable = @agent
      return
    end
    get_event
    if @event
      @attachable = @event
      return
    end
    get_shelf
    if @shelf
      @attachable = @shelf
      nil
    end
  end
end
