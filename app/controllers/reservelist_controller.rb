class ReservelistController < ApplicationController
  #before_filter :store_location, :only => :index
  #load_and_authorize_resource
  #before_filter :get_user_if_nil, :only => :index
  #before_filter :get_user, :except => :index
  #helper_method :get_item
  #after_filter :convert_charset, :only => :index

  
  def index
    @displist = []
    @DispList = Struct.new(:status_id, :dispname, :buflist)

    @status_types = RequestStatusType.find(:all, :order => 'position')

    @status_types.each_with_index do |s, i|
      @displist << @DispList.new(s.id, convert_dispname(s.id), [])

      @reserves = Reserve.find_by_sql(["SELECT item_id, item_identifier, full_name, user_number, original_title FROM reserves LEFT OUTER JOIN items ON (items.id = reserves.item_id) LEFT OUTER JOIN patrons ON (reserves.user_id = patrons.user_id) LEFT OUTER JOIN users ON (users.id = reserves.user_id) LEFT OUTER JOIN manifestations ON (manifestations.id = reserves.manifestation_id ) WHERE (reserves.request_status_type_id = ?) ORDER BY manifestation_id, user_number", s.id])

      next if @reserves.empty?

      @reserves.each_with_index do |r, j|
	r["item_identifier"] = " " if r["item_identifier"].nil?
	r["item_id"]         = " " if r["item_id"].nil?
	r["full_name"]       = " " if r["full_name"].nil?
	r["user_number"]     = " " if r["user_number"].nil?
	r["original_title"]  = " " if r["original_title"].nil?
        @displist[i].buflist[j] = {}
        @displist[i].buflist[j] = r
      end
    end

    if params[:commit]
      download("reservelist.tsv")
      return
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @manifestations }
    end
  end

  def download(fname)
    @buf = String.new
    @displist.each_with_index do |d, i|
      @buf << "\"" + d.dispname + "\"" + "\n" 
      @buf << "\"" + t('activerecord.attributes.manifestation.original_title') + "\"" + "\t" +
	"\"" + t('activerecord.attributes.user.user_number') + "\"" + "\t" +
	"\"" + t('activerecord.models.user') + "\"" + "\t" +
	"\"" + t('activerecord.attributes.item.item_identifier') + "\"" + "\t" +
        "\n"
 
      d.buflist.each do |b|
	@buf << "\"" + b["original_title"] + "\"" + "\t" +
                "\"" + b["user_number"] + "\"" + "\t" +
                "\"" + b["full_name"] + "\"" + "\t" +
                "\"" + b["item_identifier"] + "\"" + "\t" +
	        "\n"
      end
      @buf << "\n"
    end 
    send_data(@buf, :filename => fname)
  end

  def convert_dispname(status_id)
    case status_id
      when 1
        @dispname = t('reserve.pending')
      when 2
        @dispname = t('reserve.canceled')
      when 3
        @dispname = t('reserve.expired')
      when 4
        @dispname = t('reserve.retained')
      when 5
        @dispname = t('reserve.requested')
      when 6 
        @dispname = t('reserve.completed')
      else
	@dispname = nil
    end
  end
end
