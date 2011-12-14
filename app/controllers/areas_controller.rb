class AreasController < InheritedResources::Base
  before_filter :check_librarian

  def index
    @areas = Area.page(params[:page])
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
        format.xml  { render :xml => @area, :status => :created, :location => @area }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @area.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @area = Area.find(params[:id])
    respond_to do |format|
      if @area.update_attributes(params[:area])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.area'))
        format.html { redirect_to(@area) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @area.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @area = Area.find(params[:id])
    @area.destroy
    respond_to do |format|
      format.html { redirect_to(areas_url) }
      format.xml  { head :ok }
    end
  end

  private
  def check_librarian
    access_denied unless current_user && current_user.has_role?('Librarian')
  end
end
