class RetainedManifestationsController < ApplicationController
  include ReservesHelper
  before_filter :check_librarian
  before_filter :get_patron
  helper_method :get_manifestation

  def index
    @librarlies = Library.find(:all).collect{|i| [ i.display_name, i.id ] }
    @selected_library = params[:library][:id] unless params[:library].blank?
    @information_types = Reserve.information_types

    query = params[:query].to_s.strip
    @query = query.dup
    query = params[:query].gsub("-", "") if params[:query]
    query = "#{query}*" if query.size == 1

    page = params[:page] || 1

    if params[:do_search].blank?
      @retained_manifestations = Reserve.retained.order('reserves.user_id, reserves.created_at DESC').page(params[:page])
      return
    end

    flash[:notice] = t('item_list.no_list_condition') if params[:do_search] and params[:all_method].blank? and params[:method].blank?
    params[:method].concat(['3', '4', '5', '6', '7']) if !params[:method].blank? and params[:method].include?('2')
    if query.blank?
      if params[:library][:id].blank?
        @retained_manifestations = Reserve.where(:information_type_id => params[:method]).retained.order('reserves.user_id, reserves.created_at DESC').page(params[:page])
      else
        @retained_manifestations = Reserve.where(:information_type_id => params[:method], :receipt_library_id => params[:library][:id]).retained.order('reserves.user_id, reserves.created_at DESC').page(params[:page])
      end
    else
      # search reserve
      get_manifestation;
      @retained_manifestations = Reserve.search do
        fulltext query
        with(:state).equal_to 'retained'
        with(:manifestation_ids).equal_to manifestation.id if manifestation
        with(:receipt_library_id).equal_to params[:library][:id] unless params[:library][:id].blank?
        with(:information_type_id, params[:method]) unless params[:method].blank? 
     end.results
    end
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

  def output
    retained_manifestations = Reserve.retained.order('reserves.user_id, reserves.receipt_library_id, reserves.created_at DESC').page(params[:page])

    require 'thinreports'
    report = ThinReports::Report.new :layout => File.join(Rails.root, 'report', 'retained_manifestations.tlf')

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

      before_user = nil
      before_receipt_library = nil
      retained_manifestations.each do |r|
        page.list(:list).add_row do |row|
          if before_user == r.user_id 
            row.item(:line1).hide
            row.item(:user).hide
          end
          if before_receipt_library == r.receipt_library_id and before_user == r.user_id
            row.item(:line2).hide
            row.item(:receipt_library).hide
          end
          row.item(:receipt_library).value(Library.find(r.receipt_library_id).display_name)
          row.item(:title).value(r.manifestation.original_title)
          user = r.user.patron.full_name
          if configatron.reserve_print.old == true and  r.user.patron.date_of_birth
            age = (Time.now.strftime("%Y%m%d").to_f - r.user.patron.date_of_birth.strftime("%Y%m%d").to_f) / 10000
            age = age.to_i
            user = user + '(' + age.to_s + t('activerecord.attributes.patron.old')  +')'
          end
          row.item(:user).value(user)
          information_method = i18n_information_type(r.information_type_id)
          information_method += ': ' + Reserve.get_information_method(r) if r.information_type_id != 0 and !Reserve.get_information_method(r).nil?
          row.item(:information_method).value(information_method)
        end
        before_user = r.user_id
        before_receipt_library = r.receipt_library_id
      end
    end
    send_data report.generate, :filename => configatron.configatron.retained_manifestations_print.filename, :type => 'application/pdf', :disposition => 'attachment'

  end
end
