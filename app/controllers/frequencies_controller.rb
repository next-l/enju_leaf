class FrequenciesController < InheritedResources::Base
  respond_to :html, :xml
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def update
    @frequency = Frequency.find(params[:id])
    if params[:position]
      @frequency.insert_at(params[:position])
      redirect_to frequencies_url
      return
    end
    update!
  end

  private
  def interpolation_options
    {:resource_name => t('activerecord.models.frequency')}
  end
end
