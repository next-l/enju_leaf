class SystemConfigurationsController < ApplicationController
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def index
    @system_configurations = SystemConfiguration.all
  end

  def new
    @system_configuration = SystemConfiguration.new
  end

  def create
    @system_configuration = SystemConfiguration.new(params[:system_configuration])

    respond_to do |format|
      if @system_configuration.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.system_configuration'))
        format.html { redirect_to(@system_configuration) }
        format.xml  { render :xml => @system_configuration, :status => :created, :location => @system_configuration }
      else
        #prepare_options
        format.html { render :action => "new" }
        format.xml  { render :xml => @system_configuration.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @system_configuration = SystemConfiguration.find(params[:id])
  end

  def update
    @system_configuration = SystemConfiguration.find(params[:id])

    respond_to do |format|
      if @system_configuration.update_attributes(params[:system_configuration])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.system_configuration'))
        format.html { redirect_to(@system_configuration) }
        format.xml  { head :ok }
      else
        #prepare_options
        format.html { render :action => "edit" }
        format.xml  { render :xml => @system_configuration.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    @system_configuration = SystemConfiguration.find(params[:id])
  end

  def destroy
    @system_configuration = SystemConfiguration.find(params[:id])
    @system_configuration.destroy

    respond_to do |format|
      format.html { redirect_to(system_configurations_url) }
      format.xml  { head :ok }
    end
  end
end
