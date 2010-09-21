class MessageTemplatesController < InheritedResources::Base
  respond_to :html, :xml
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @message_template = MessageTemplate.find(params[:id])
    if params[:position]
      @message_template.insert_at(params[:position])
      redirect_to message_templates_url
      return
    end
    update!
  end

  protected
  def collection
    @message_templates ||= end_of_association_chain.paginate(:page => params[:page])
  end

  private
  def interpolation_options
    {:resource_name => t('activerecord.models.message_template')}
  end
end
