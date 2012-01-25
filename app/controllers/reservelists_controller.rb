class ReservelistsController < ApplicationController
  include ReservesHelper
  before_filter :check_librarian
  
  def initialize
    @states = @selected_state= Reserve.states
    @information_types = @selected_method = Reserve.information_types
    @libraries = Library.order('position')
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
    @selected_method = params[:method] || []
    selected_method = params[:method].clone.concat(['3', '4', '5', '6', '7']) if !params[:method].blank? and params[:method].include?('2')

    # wrong checked
    if params[:state].blank? || params[:library].blank? || params[:method].blank?
      flash[:reserve_notice] = t('item_list.no_list_condition')
      @states.each_with_index do |state, i|
        @reserves = Reserve.where(:state => state).order('created_at DESC')
        @displist << dispList.new(state, @reserves)
      end
      render :index; return
    end

    # set list
    @selected_state.each do |state|
      @reserves = Reserve.where(:state => state, :receipt_library_id => @selected_library, :information_type_id => selected_method).order('created_at DESC')
      @displist << dispList.new(state, @reserves)
    end

    if params[:output_pdf]
      output_pdf
    elsif params[:output_tsv]
      output_tsv
    end
  end

  private
  def output_pdf
    # thinreports
    require 'thinreports'
    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'reservelist.tlf')

    # set page_number
    report.events.on :page_create do |e|
      e.page.item(:page).value(e.page.no)
    end
    report.events.on :generate do |e|
      e.pages.each do |page|
        page.item(:total).value(e.report.page_count)
      end
    end

    report.start_new_page do |page|
      page.item(:date).value(Time.now)
      before_state = nil

      @displist.each do |d|
        before_receipt_library = nil
        #reserves = Reserve.where(:state => d.state, :receipt_library_id => params[:library], :information_type_id => params[:method]).order('expired_at ASC').includes(:manifestation) 
        unless d.reserves.blank?
          d.reserves.each do |r|
            page.list(:list).add_row do |row|
             row.item(:not_found).hide
             if before_state == d.state
               row.item(:state_line).hide
               row.item(:state).hide
             end
             if before_receipt_library == r.receipt_library_id and before_state == d.state
               row.item(:receipt_library_line).hide
               row.item(:receipt_library).hide
             end
               row.item(:state).value(i18n_state(d.state))
               row.item(:receipt_library).value(Library.find(r.receipt_library_id).display_name)
               row.item(:title).value(r.manifestation.original_title)
               row.item(:expired_at).value(r.expired_at.strftime("%Y/%m/%d"))
               user = r.user.patron.full_name
               if SystemConfiguration.get("reserve_print.old") == true and  r.user.patron.date_of_birth
                 age = (Time.now.strftime("%Y%m%d").to_f - r.user.patron.date_of_birth.strftime("%Y%m%d").to_f) / 10000
                 age = age.to_i
                 user = user + '(' + age.to_s + t('activerecord.attributes.patron.old')  +')'
                end
               row.item(:user).value(user)
               information_method = i18n_information_type(r.information_type_id)
               information_method += ': ' + Reserve.get_information_method(r) if r.information_type_id != 0 and !Reserve.get_information_method(r).nil?
               row.item(:information_method).value(information_method)
            end
            before_receipt_library = r.receipt_library_id
            before_state = d.state
          end
        else
          page.list(:list).add_row do |row|
            row.item(:state).value(i18n_state(d.state))
            row.item(:not_found).show
            row.item(:not_found).value(t('page.no_record_found'))
            row.item(:line2).hide
            row.item(:line3).hide
            row.item(:line4).hide
            row.item(:line5).hide
          end
        end
      end
      send_data report.generate, :filename => configatron.reservelist_report_pdf.filename, :type => 'application/pdf', :disposition => 'attachment'
    end
  end

  def output_tsv
    @buf = String.new
    @displist.each do |d|
      @buf << "\"" + i18n_state(d.state) + "\"" + "\n" 
      @buf << "\"" + t('activerecord.attributes.manifestation.original_title') + "\"" + "\t" +
	"\"" + t('activerecord.attributes.user.user_number') + "\"" + "\t" +
	"\"" + t('activerecord.models.user') + "\"" + "\t" +
	"\"" + t('activerecord.attributes.item.item_identifier') + "\"" + "\t" +
        "\n"
      d.reserves.each do |reserve|
        original_title = ""
        original_title = reserve.manifestation.original_title unless reserve.manifestation.original_title.blank?
        user_number = ""
        user_number = reserve.user.user_number unless reserve.user.user_number.blank?
        full_name = ""
        full_name = reserve.user.patron.full_name unless reserve.user.patron.full_name.blank?
        item_identifier = ""
        item_identifier = reserve.item.item_identifier if !reserve.item.blank? and !reserve.item.item_identifier.blank?
	@buf << "\"" + original_title + "\"" + "\t" +
                "\"" + user_number + "\"" + "\t" +
                "\"" + full_name + "\"" + "\t" +
                "\"" + item_identifier + "\"" + "\t" +
	        "\n"
      end
      @buf << "\n"
    end 
    send_data(@buf, :filename => configatron.reservelist_report_tsv.filename)
  end
end
