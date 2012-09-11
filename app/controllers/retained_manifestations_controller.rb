class RetainedManifestationsController < ApplicationController
  before_filter :check_librarian
  before_filter :get_real_libraries
  before_filter :get_reserve_information_types

  def index
    unless params[:commit]
      @selected_information_type = @reserve_information_types
    else
      @selected_library = params[:library][:id] 
      @selected_information_type = params[:information_type] || []
      @selected_information_type = @selected_information_type.map { |i|i.split }
      @selected_information_type = @selected_information_type.inject([]) do |types, type|
        type = type.map{ |i| i.to_i }
        type = type.join().to_i if type.size == 1
        types << type
      end
      @query = params[:query].to_s.strip.dup
      @date_of_birth = params[:birth_date].to_s.dup
      @address = params[:address]
      query, notice = User.set_query(params[:query], params[:birth_date], params[:address])
      flash[:notice] = ""
      flash[:notice] << t('item_list.no_list_condition') + '<br />' if @selected_information_type.blank?
      flash[:notice] << notice unless notice.blank? 
    end

    page = params[:page] || 1
    selected_information_type = @selected_information_type.flatten
    unless flash[:notice].blank?
      # @retained_manifestations = Reserve.retained.order('user_id DESC, expired_at ASC').page(page)
      @retained_manifestations = Reserve.where(:id => 0).page(page)
      render :index, :formats => 'html'; return
    else
      @retained_manifestations = Reserve.search do
        fulltext query if query
        with(:state).equal_to 'retained'
        with(:retained).equal_to false
        with(:receipt_library_id).equal_to params[:library][:id] if params[:library].present? and params[:library][:id].present?
        with(:information_type_id, selected_information_type) if params[:information_type].present?
        order_by(:user_id, :desc)
        order_by(:expired_at, :asc)
        paginate :page => page.to_i, :per_page => Reserve.per_page if params[:format] == 'html' || params[:format].nil?
      end.results
    end

    respond_to do |format|
      format.html # index.html.erb
      format.pdf { send_data Reserve.get_retained_manifestation_list_pdf(@retained_manifestations).generate, 
        :filename => Setting.retained_manifestation_list_print_pdf.filename }
      format.tsv { send_data Reserve.get_retained_manifestation_list_tsv(@retained_manifestations), 
        :filename => Setting.retained_manifestation_list_print_tsv.filename  }
    end
  end

  def informed
    @reserve = Reserve.find(params[:reserve][:id])
    @reserve.retained = params[:reserve][:retained]
    @reserve.save!(:validate => false)
    respond_to do |format|
      format.html { redirect_to retained_manifestations_path }
      format.json { head :no_content }
    end
  end
end
