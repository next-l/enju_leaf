class ThemasController < InheritedResources::Base




  def update
    @thema = Thema.find(params[:id])
      if params[:move]
      move_position(@thema, params[:move])
      return
      end
    update!
  end
end
