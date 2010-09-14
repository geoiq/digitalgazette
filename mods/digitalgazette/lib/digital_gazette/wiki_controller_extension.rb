module DigitalGazette
  module WikiControllerExtension
    def self.included(base)
      base.instance_eval do
        before_filter :login_required, :except => [:show, :image_popup_show, :link_popup_show, :image_popup_upload, :map_popup_show]
      end
    end
  end
end
