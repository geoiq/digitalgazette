module DigitalGazette
  module ControllerExtensionWikiPopupExtension
    def map_popup_show
      render :partial => 'wiki/map_popup', :locals => {:wiki => @wiki}
    end
  end
end
