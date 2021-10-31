class MessageTemplatesController < ApplicationController
  before_action :set_message_template, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /message_templates
  # GET /message_templates.json
  def index
    @message_templates = MessageTemplate.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @message_templates }
    end
  end

  # GET /message_templates/1
  # GET /message_templates/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @message_template }
    end
  end

  # GET /message_templates/new
  # GET /message_templates/new.json
  def new
    @message_template = MessageTemplate.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @message_template }
    end
  end

  # GET /message_templates/1/edit
  def edit
  end

  # POST /message_templates
  # POST /message_templates.json
  def create
    @message_template = MessageTemplate.new(message_template_params)

    respond_to do |format|
      if @message_template.save
        format.html { redirect_to @message_template, notice:  t('controller.successfully_created', model: t('activerecord.models.message_template')) }
        format.json { render json: @message_template, status: :created, location: @message_template }
      else
        format.html { render action: "new" }
        format.json { render json: @message_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /message_templates/1
  # PUT /message_templates/1.json
  def update
    if params[:move]
      move_position(@message_template, params[:move])
      return
    end

    respond_to do |format|
      if @message_template.update(message_template_params)
        format.html { redirect_to @message_template, notice:  t('controller.successfully_updated', model: t('activerecord.models.message_template')) }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @message_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /message_templates/1
  # DELETE /message_templates/1.json
  def destroy
    @message_template.destroy

    respond_to do |format|
      format.html { redirect_to message_templates_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.message_template')) }
      format.json { head :no_content }
    end
  end

  private

  def set_message_template
    @message_template = MessageTemplate.find(params[:id])
    authorize @message_template
  end

  def check_policy
    authorize MessageTemplate
  end

  def message_template_params
    params.require(:message_template).permit(:status, :title, :body, :locale)
  end
end
