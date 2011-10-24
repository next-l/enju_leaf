class FormOfWorksController < InheritedResources::Base
  respond_to :html, :xml
  load_and_authorize_resource

  def update
    @form_of_work = FormOfWork.find(params[:id])
    if params[:position]
      @form_of_work.insert_at(params[:position])
      redirect_to form_of_works_url
      return
    end
    update!
  end
end
