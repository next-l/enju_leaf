class SystemConfigurationsController < ApplicationController
  include SystemConfigurationsHelper
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def index
    #@system_configurations = SystemConfiguration.all
    @category = 'general'
    @category = params[:system_configuration][:category] if params[:system_configuration]
    @system_configurations = SystemConfiguration.where(:category => @category)
  end

  def update
    @errors = []
    error = Struct.new(:id, :msg, :v)
    params[:system_configurations].each do |id, value|
      begin
        system_configuration = SystemConfiguration.find(id.to_i)
        system_configuration.v = value
        system_configuration.save!
      rescue Exception => e
        @errors << error.new(id, e, value)
        logger.error "system_configurations update error: #{e}"
      end
    end
  
    respond_to do |format|
      if @errors.blank?
        format.html { redirect_to system_configurations_path(:system_configuration => { :category => params[:category] }),
          :notice => t('controller.successfully_updated', :model => t('activerecord.models.system_configuration')) }
        format.json { head :no_content }
      else
        @category = params[:category]
        @system_configurations = SystemConfiguration.where(:category => @category)
        format.html { render :action => "index" }
        format.json { render :json => @system_configurations.errors, :status => :unprocessable_entity }
      end
    end    
  end
end
