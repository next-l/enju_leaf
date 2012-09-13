class PictureFilesController < ApplicationController
  load_and_authorize_resource
  before_filter :get_attachable, :only => [:index, :new]
  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]

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
      format.json { render :json => @picture_files }
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

    if @picture_file.picture.path
      if Setting.uploaded_file.storage == :s3
        data = open(@picture_file.picture.url(size)).read.force_encoding('UTF-8')
      else
        file = @picture_file.picture.path(size)
      end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @picture_file }
      format.download {
        if @picture_file.picture.path
          if Setting.uploaded_file.storage == :s3
            send_data data, :filename => @picture_file.picture_file_name, :type => @picture_file.picture_content_type, :disposition => 'attachment'
          else
            send_file file, :filename => @picture_file.picture_file_name, :type => @picture_file.picture_content_type, :disposition => 'attachment'
          end
        end
      }
      format.jpeg {
        if @picture_file.picture.path
          if Setting.uploaded_file.storage == :s3
            send_data data, :filename => @picture_file.picture_file_name, :type => 'image/jpeg', :disposition => 'inline'
          else
            send_file file, :filename => @picture_file.picture_file_name, :type => 'image/jpeg', :disposition => 'inline'
          end
        end
      }
      format.gif {
        if @picture_file.picture.path
          if Setting.uploaded_file.storage == :s3
            send_data data, :filename => @picture_file.picture_file_name, :type => 'image/gif', :disposition => 'inline'
          else
            send_file file, :filename => @picture_file.picture_file_name, :type => 'image/gif', :disposition => 'inline'
          end
        end
      }
      format.png {
        if @picture_file.picture.path
          if Setting.uploaded_file.storage == :s3
            send_data data, :filename => @picture_file.picture_file_name, :type => 'image/png', :disposition => 'inline'
          else
            send_file file, :filename => @picture_file.picture_file_name, :type => 'image/png', :disposition => 'inline'
          end
        end
      }
      format.svg {
        if @picture_file.picture.path
          if Setting.uploaded_file.storage == :s3
            send_data data, :filename => @picture_file.picture_file_name, :type => 'image/svg+xml', :disposition => 'inline'
          else
            send_file file, :filename => @picture_file.picture_file_name, :type => 'image/svg+xml', :disposition => 'inline'
          end
        end
      }
    end
  end

  # GET /picture_files/new
  # GET /picture_files/new.json
  def new
    unless @attachable
      redirect_to picture_files_url
      return
    end
    #raise unless @event or @manifestation or @shelf or @patron
    @picture_file = PictureFile.new
    @picture_file.picture_attachable = @attachable

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @picture_file }
    end
  end

  # GET /picture_files/1/edit
  def edit
  end

  # POST /picture_files
  # POST /picture_files.json
  def create
    @picture_file = PictureFile.new(params[:picture_file])

    respond_to do |format|
      if @picture_file.save
        format.html { redirect_to @picture_file, :notice => t('controller.successfully_created', :model => t('activerecord.models.picture_file')) }
        format.json { render :json => @picture_file, :status => :created, :location => @picture_file }
      else
        format.html { render :action => "new" }
        format.json { render :json => @picture_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /picture_files/1
  # PUT /picture_files/1.json
  def update
    # 並べ替え
    if params[:move]
      move_position(@picture_file, params[:move])
      return
    end

    respond_to do |format|
      if @picture_file.update_attributes(params[:picture_file])
        format.html { redirect_to @picture_file, :notice => t('controller.successfully_updated', :model => t('activerecord.models.picture_file')) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @picture_file.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /picture_files/1
  # DELETE /picture_files/1.json
  def destroy
    obj = @picture_file.picture_attachable
    case
    when @picture_file.picture_attachable.is_a?(Shelf)
      type = 'Shelf'
    when @picture_file.picture_attachable.is_a?(Manifestation)
      type = 'Manifestation'
    when @picture_file.picture_attachable.is_a?(Patron)
      type = 'Patron'
    when @picture_file.picture_attachable.is_a?(Event)
      type = 'Event'
    else
      type = nil
    end

    @picture_file.destroy

    respond_to do |format|
      case type
      when 'Shelf'
        format.html { redirect_to shelf_picture_files_url(obj) }
        format.json { head :no_content }
      when 'Manifestation'
        format.html { redirect_to manifestation_picture_files_url(obj) }
        format.json { head :no_content }
      when 'Patron'
        format.html { redirect_to patron_picture_files_url(obj) }
        format.json { head :no_content }
      when 'Event'
        format.html { redirect_to event_picture_files_url(obj) }
        format.json { head :no_content }
      else
        format.html { redirect_to picture_files_url }
        format.json { head :no_content }
      end
    end
  end

  private
  def get_attachable
    get_manifestation
    if @manifestation
      @attachable = @manifestation
      return
    end
    get_patron
    if @patron
      @attachable = @patron
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
      return
    end
  end
end
