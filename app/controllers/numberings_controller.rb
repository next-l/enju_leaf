class NumberingsController < InheritedResources::Base
  before_filter :check_librarian
  load_and_authorize_resource

  def index
    page = params[:page] || 1
    @numberings = Numbering.page(page)
  end

  def create
    @numbering = Numbering.new(params[:numbering])
    respond_to do |format|
      if @numbering.save
        flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.numbering'))
        format.html { redirect_to(@numbering) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @numbering = Numbering.find(params[:id])
    respond_to do |format|
      if @numbering.update_attributes(params[:numbering])
        flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.numbering'))
        format.html { redirect_to(@numbering) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

end
