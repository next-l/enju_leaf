class UserImportResultsController < InheritedResources::Base
  respond_to :html, :json, :tsv
  load_and_authorize_resource
  has_scope :file_id
  actions :index, :show, :destroy

  def index
    @user_import_file = UserImportFile.where(:id => params[:user_import_file_id]).first
    if @user_import_file
      @user_import_results = @user_import_file.user_import_results.page(params[:page])
    else
      @user_import_results = UserImportResult.page(params[:page])
    end
  end
end
