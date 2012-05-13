class RetainedManifestationsController < ApplicationController
  include ReservesHelper
  before_filter :check_librarian

  def index
    flash[:notice] = ""
    page = params[:page] || 1
    @librarlies = @selected_library = Library.real.find(:all).map{|i| [ i.display_name, i.id ] }
    @selected_library = params[:library][:id] if !params[:library].blank? and !params[:library][:id].blank?
    @information_types = @selected_information_type = Reserve.information_type_ids
    @selected_information_type = [] if params[:commit] or params[:output_pdf] or params[:output_tsv]
    if params[:information_type]
      @selected_information_type = params[:information_type].map{|i|i.split}
      @selected_information_type = @selected_information_type.inject([]){|types, type| 
        type = type.map{|i| i.to_i}
        type = type.join().to_i if type.size == 1
        types << type
      }
    end
    selected_information_type = @selected_information_type.flatten
    # check conditions 
    if params[:commit] or params[:output_pdf] or params[:output_tsv]
      flash[:notice] << t('item_list.no_list_condition') + '<br />' if @selected_information_type.blank?
    end

    # set query
    query = params[:query].to_s.strip
    @query = query.dup
    query = params[:query].gsub("-", "") if params[:query]
    query = "#{query}*" if query.size == 1
    @address = params[:address]
    @date_of_birth = params[:birth_date].to_s.dup
    birth_date = params[:birth_date].to_s.gsub(/\D/, '') if params[:birth_date]
    unless params[:birth_date].blank?
      begin
        date_of_birth = Time.zone.parse(birth_date).beginning_of_day.utc.iso8601
      rescue
        flash[:notice] << t('user.birth_date_invalid')
      end
    end
    date_of_birth_end = Time.zone.parse(birth_date).end_of_day.utc.iso8601 rescue nil
    query = "#{query} date_of_birth_d:[#{date_of_birth} TO #{date_of_birth_end}]" unless date_of_birth.blank?
    query = "#{query} address_text:#{@address}" unless @address.blank?

    if query.blank?
      if params[:output_pdf] or params[:output_tsv]
        @retained_manifestations = Reserve.where(:information_type_id => selected_information_type, :receipt_library_id => @selected_library).retained.order('user_id DESC, expired_at ASC')
      else
        @retained_manifestations = Reserve.where(:information_type_id => selected_information_type, :receipt_library_id => @selected_library).retained.order('user_id DESC, expired_at ASC').page(page)
      end
    else
      @retained_manifestations = Reserve.search do
        fulltext query
        with(:state).equal_to 'retained'
        with(:receipt_library_id).equal_to @selected_library unless @selected_library.blank?
        with(:information_type_id, selected_information_type) 
        order_by(:user_id, :desc)
        order_by(:expired_at, :asc)
        paginate :page => page.to_i, :per_page => Reserve.per_page unless params[:output_pdf] or params[:output_tsv]
     end.results
    end
    # output
    if params[:output_pdf]
      data = RetainedManifestation.get_retained_manifestation_list_pdf(@retained_manifestations)
      send_data data.generate, :filename => configatron.configatron.retained_manifestation_list_print_pdf.filename
    end
    if params[:output_tsv]
      data = RetainedManifestation.get_retained_manifestation_list_tsv(@retained_manifestations)
      send_data data, :filename => configatron.configatron.retained_manifestation_list_print_tsv.filename
    end
  end

  def set_retained
    @reserve = Reserve.find(params[:reserve][:id])
    @reserve.retained = params[:reserve][:retained]
    @reserve.save!(:validate => false)
    respond_to do |format|
      format.html { redirect_to retained_manifestations_path }
      format.json { head :no_content }
    end
  end
end
