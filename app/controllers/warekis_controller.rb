class WarekisController < ApplicationController
   load_and_authorize_resource

   def index
     @warekis = Wareki.page(params[:page])
   end

   def create
     @wareki = Wareki.new(params[:wareki])
     if @wareki.save
       flash[:notice] = t('controller.successfully_created', :model => t('activerecord.models.wareki'))
       redirect_to(@wareki) 
     else
       render :action => "new" 
     end
   end

   def update
     @wareki = Wareki.find(params[:id])

     if @wareki.update_attributes(params[:wareki])
       flash[:notice] = t('controller.successfully_updated', :model => t('activerecord.models.wareki'))
       redirect_to(@wareki) 
     else
       render :action => "edit" 
     end
   end

   def destroy
     @wareki = Wareki.find(params[:id])
     @wareki.destroy
     redirect_to(warekis_url) 
   end

end
