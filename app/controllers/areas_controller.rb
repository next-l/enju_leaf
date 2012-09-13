class AreasController < InheritedResources::Base
  before_filter :check_librarian

  def index
    query = params[:query].to_s.strip
    @query = query.dup
    query = "#{query}*" if query.size == 1
    page = params[:page] || 1

    unless query.blank?
      @areas = Area.search do
        fulltext query
          paginate :page => page.to_i, :per_page => Area.default_per_page
      end.results
    else
      @areas = Area.page(page)
    end
  end

  def show
    @area = Area.find(params[:id])
  end

  def new
    @area = Area.new
  end

  def edit
    @area = Area.find(params[:id])
  end

  def create
    @area = Area.new(params[:area])
      respond_to do |format|
      if @area.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.area'))
        format.html { redirect_to(@area) }
        format.json { render :json => @area, :status => :created, :location => @area }
      else
        format.html { render :action => "new" }
        format.json { render :json => @area.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @area = Area.find(params[:id])
    respond_to do |format|
      if @area.update_attributes(params[:area])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.area'))
        format.html { redirect_to(@area) }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @area.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @area = Area.find(params[:id])
    @area.destroy
    respond_to do |format|
      format.html { redirect_to(areas_url) }
      format.json { head :no_content }
    end
  end

  private
  def check_librarian
    access_denied unless current_user && current_user.has_role?('Librarian')
  end
end
