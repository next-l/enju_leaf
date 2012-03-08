class ReservelistsController < ApplicationController
  before_filter :check_librarian
  
  def initialize
    @states = @selected_state= Reserve.states
    @information_types = @selected_information_type = Reserve.information_type_ids
    @libraries = Library.real.order('position')
    @selected_library = @libraries.collect{|library| library.id}
    super
  end

  def index
    @displist = []
    dispList = Struct.new(:state, :reserves)
    @states.each do |state|
      @reserves = Reserve.where(:state => state).order('created_at DESC')
      @displist << dispList.new(state, @reserves)
    end
  end

  def output
    @displist = []
    dispList = Struct.new(:state, :reserves)

    # check list_conditions
    @selected_state = params[:state] || []
    @selected_library = params[:library] ||  []
    @selected_information_type = params[:information_type] || []
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
    if @selected_state.blank? || @selected_library.blank? || @selected_information_type.blank?
      flash[:reserve_notice] = t('item_list.no_list_condition')
      @states.each_with_index do |state, i|
        @reserves = Reserve.where(:state => state).order('created_at DESC')
        @displist << dispList.new(state, @reserves)
      end
      render :index; return
    end

    # set list
    @selected_state.each do |state|
      @reserves = Reserve.where(:state => state, :receipt_library_id => @selected_library, :information_type_id => selected_information_type).order('created_at DESC')
      @displist << dispList.new(state, @reserves)
    end

    send_data Reserve.get_reservelist_pdf(@displist).generate, :filename => configatron.reservelist_report_pdf.filename if params[:pdf]
    send_data Reserve.get_reservelist_tsv(@displist), :filename => configatron.reservelist_report_tsv.filename if params[:tsv]
  end
end
