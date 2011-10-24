class CheckoutlistController < ApplicationController
  #before_filter :store_location, :only => :index
  #load_and_authorize_resource
  #before_filter :get_user_if_nil, :only => :index
  #before_filter :get_user, :except => :index
  #helper_method :get_item
  #after_filter :convert_charset, :only => :index

  def index
    @checkoutlists = []
    @circulation_ids = Item.find(:all, :group => "circulation_status_id", :select => "circulation_status_id", :order => "circulation_status_id")
    @circulation_ids.each do |id|
    
    end 
  end
end
