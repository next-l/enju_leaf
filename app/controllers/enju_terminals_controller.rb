class EnjuTerminalsController < ApplicationController
  load_and_authorize_resource

  def index
    @enju_terminals = EnjuTerminal.page(params[:page])
  end

  def create
    @enju_terminal = EnjuTerminal.new(params[:enju_terminal])

    respond_to do |format|
      if @enju_terminal.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.enju_terminal'))
        format.html { redirect_to(@enju_terminal) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    respond_to do |format|
      if @enju_terminal.update_attributes(params[:enju_terminal])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.enju_terminal'))
        format.html { redirect_to(@enju_terminal) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @enju_terminal.destroy

    respond_to do |format|
      format.html { redirect_to enju_terminals_url, :notice => t('controller.successfully_deleted', :model => t('activerecord.models.enju_terminal')) }
    end
  end

end
