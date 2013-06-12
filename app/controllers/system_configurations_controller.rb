# -*- encoding: utf-8 -*-
class SystemConfigurationsController < ApplicationController
  include SystemConfigurationsHelper
  before_filter :check_client_ip_address
  load_and_authorize_resource

  def index
    #@system_configurations = SystemConfiguration.all
    @category = 'general'
    @category = params[:system_configuration][:category] if params[:system_configuration]
    @system_configurations = SystemConfiguration.where(:category => @category)
    @roles = Role.find(:all, :select => 'name, display_name') if @category == 'purchase_request'
  end

  def update
    @errors = []
    error = Struct.new(:id, :msg, :v)
    params[:system_configurations].each do |id, value|
      begin
        system_configuration = SystemConfiguration.find(id.to_i)

        # for exclude_patrons
        old_exclude_patrons, new_exclude_patrons = nil, nil
        if system_configuration.keyname == 'exclude_patrons'
          old_exclude_patrons = system_configuration.v.split(',').inject([]){ |list, word| list << word.gsub(/^[　\s]*(.*?)[　\s]*$/, '\1') }
          new_exclude_patrons = value.split(',').inject([]){ |list, word| list << word.gsub(/^[　\s]*(.*?)[　\s]*$/, '\1') }
        end

        system_configuration.v = value
        system_configuration.save!

        # for exclude_patrons
        set_exclude_patrons(old_exclude_patrons, new_exclude_patrons) if system_configuration.keyname == 'exclude_patrons'
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

  private
  def set_exclude_patrons(old_exclude_patrons, new_exclude_patrons)
    old_exclude_patrons.each do |p|
      next if new_exclude_patrons.include?(p)
      patron = Patron.where(:full_name => p).first
      if patron
        if patron.manifestations.size == 0 && patron.works.size == 0 && patron.expressions.size == 0
          patron.destroy
        else
          patron.exclude_state = 0
          patron.save!
        end
      end
    end
    new_exclude_patrons.each do |p|
      patron = Patron.where(:full_name => p).first
      unless patron
        patron = Patron.new
        patron.full_name = p
      end
      patron.exclude_state = 1
      patron.save!
    end
  end
end
