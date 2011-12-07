class LossItemsController < ApplicationController
  def index
    @loss_items = LossItem.all
  end

  def edit
  end

  def update
    @loss_item = Family.find(params[:id])
    @loss_item.update_attributes(params[:loss_item])
    flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.loss_item'))
    format.html { redirect_to(@family) }
  end
end
