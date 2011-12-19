class RetainedManifestationsController < ApplicationController
  before_filter :check_librarian

  def index
    @librarlies = Library.find(:all).collect{|i| [ i.display_name, i.id ] }
    @selected_library = params[:library][:id] unless params[:library].blank?
    @information_types = Reserve.information_types

    @send_message = MessageTemplate.where(:status => 'retained_manifestations').first
    @retained_manifestations = Reserve.retained.order('reserves.user_id, reserves.created_at DESC').page(params[:page])
  end

  def set_retained
    @reserve = Reserve.find(params[:reserve][:id])
    @reserve.retained = params[:reserve][:retained]
    @reserve.save!(:validate => false)
    respond_to do |format|
      format.html { redirect_to retained_manifestations_path }
      format.xml  { head :ok }
    end
  end
end
