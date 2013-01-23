class TerminalsController < ApplicationController
  load_and_authorize_resource

  def index
    @terminals = Terminal.page(params[:page])
  end

  def create
    @terminal = Terminal.new(params[:terminal])

    respond_to do |format|
      if @terminal.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.terminal'))
        format.html { redirect_to(@terminal) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    respond_to do |format|
      if @terminal.update_attributes(params[:terminal])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.terminal'))
        format.html { redirect_to(@terminal) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @terminal.destroy

    respond_to do |format|
      format.html { redirect_to terminals_url, :notice => t('controller.successfully_deleted', :model => t('activerecord.models.terminal')) }
    end
  end

end
