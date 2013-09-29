class CheckedManifestationsController < ApplicationController
  before_filter :get_current_basket
  before_filter :get_manifestation
  before_filter :prepare_options

  def create
    #TODO
    unless @current_basket
      @error = "cannot get basket"
    end
    begin
      @current_basket.checked_manifestations.create!(:manifestation_id => params[:manifestation_id]) 
    rescue Exception => e
      @error = e
    end
    render :action => :update
  end

  def destroy
    #TODO unless @current_basket
    begin 
      @current_basket.checked_manifestations.where(:manifestation_id => params[:manifestation_id]).first.destroy
    rescue Exception => e
      logger.error e
    end
    render :action => :update
  end

  def get_current_basket
    if current_user
      @current_basket = current_user.current_basket || Basket.create(:type => 1, :user_id => current_user.id)
    end
  end

  def prepare_options
    @index_patron = get_index_patron
  end
end
