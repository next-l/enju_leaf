class MessageRequestsController < ApplicationController
  before_action :set_message_request, only: [:show, :edit, :update, :destroy]
  before_action :check_policy, only: [:index, :new, :create]

  # GET /message_requests
  # GET /message_requests.json
  def index
    case params[:mode]
    when 'sent'
      @message_requests = MessageRequest.sent.order('created_at DESC').page(params[:page])
    when 'all'
      @message_requests = MessageRequest.order('created_at DESC').page(params[:page])
    else
      @message_requests = MessageRequest.not_sent.order('created_at DESC').page(params[:page])
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @message_requests }
    end
  end

  # GET /message_requests/1
  # GET /message_requests/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @message_request }
    end
  end

  # GET /message_requests/1/edit
  def edit
    @message_templates = MessageTemplate.order(:position)
  end

  # PUT /message_requests/1
  # PUT /message_requests/1.json
  def update
    respond_to do |format|
      if @message_request.update(message_request_params)
        flash[:notice] = t('controller.successfully_updated', model: t('activerecord.models.message_request'))
        format.html { redirect_to(@message_request) }
        format.json { head :no_content }
      else
        @message_templates = MessageTemplate.order(:position)
        format.html { render action: "edit" }
        format.json { render json: @message_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /message_requests/1
  # DELETE /message_requests/1.json
  def destroy
    @message_request.destroy

    respond_to do |format|
      format.html { redirect_to message_requests_url, notice: t('controller.successfully_deleted', model: t('activerecord.models.message_request')) }
      format.json { head :no_content }
    end
  end

  private

  def set_message_request
    @message_request = MessageRequest.find(params[:id])
    authorize @message_request
  end

  def check_policy
    authorize MessageRequest
  end

  def message_request_params
    params.require(:message_request).permit(
      :body,
      :sender, :receiver, :message_template, :body # , as: :admin
    )
  end
end
