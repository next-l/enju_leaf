class ReservelistsController < ApplicationController
  before_filter :check_librarian
  before_filter :get_real_libraries
  before_filter :get_reserve_states
  before_filter :get_reserve_information_types

  def index
    @displist = []
    dispList = Struct.new(:state, :reserves)

    unless params[:format] == 'pdf' or params[:format] == 'tsv'
      @selected_state = @reserve_states 
      @selected_library = @libraries.collect{|library| library.id}
      @selected_information_type = @reserve_information_types
    else
      @selected_state = params[:state] || []
      @selected_library = params[:library] ||  []
      @selected_information_type = params[:information_type] || []
      @selected_information_type = @selected_information_type.map{|i|i.split}
      @selected_information_type = @selected_information_type.inject([]){ |types, type|
        type = type.map{|i| i.to_i}
        type = type.join().to_i if type.size == 1
        types << type
      }
    end
    if @selected_state.blank? or @selected_library.blank? or @selected_information_type.blank?
      @reserve_states.each do |state|
        @reserves = Reserve.where(:state => state).order('created_at DESC')
        @displist << dispList.new(state, @reserves)
      end
      flash[:reserve_notice] = t('item_list.no_list_condition')
      render :index, :formats => 'html'; return
    end
    selected_information_type = @selected_information_type.flatten

    @selected_state.each do |state|
      @reserves = Reserve.where(:state => state, :receipt_library_id => @selected_library, :information_type_id => selected_information_type).order('created_at DESC')
      @displist << dispList.new(state, @reserves)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.pdf { send_data Reserve.get_reservelist_pdf(@displist).generate, :filename => Setting.reservelist_report_pdf.filename }
      format.tsv { send_data Reserve.get_reservelist_tsv(@displist), :filename => Setting.reservelist_report_tsv.filename }
    end
  end
end
