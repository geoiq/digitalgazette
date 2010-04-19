module ControllerExtension::MapPopup
  puts "*"*40 + "LOADING MapPopup"
  def map_popup_show
    render :partial => 'wiki/map_popup', :locals => {:wiki => @wiki}
  end
end