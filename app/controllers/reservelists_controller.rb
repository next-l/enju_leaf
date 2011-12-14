class ReservelistsController < ApplicationController
  include ReservesHelper
  before_filter :check_librarian
  
  def index
    @displist = []
    @DispList = Struct.new(:state, :reserves)
    @states = Reserve.states
    @information_types = Reserve.information_types
    @libraries = Library.order('position')
    @states.each_with_index do |state, i|
      @reserves = Reserve.where(:state => state).order('created_at DESC')
      @displist << @DispList.new(state, @reserves)
    end

    if params[:commit] == t('page.download')
      download("reservelist.tsv")
      return
    end
  end

  private
  def download(fname)
    @buf = String.new
    @displist.each_with_index do |d, i|
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
    send_data(@buf, :filename => fname)
  end

  def check_librarian
    access_denied unless current_user && current_user.has_role?('Librarian')
  end
end
