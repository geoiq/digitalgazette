class DigitalGazette::ViewListener < Crabgrass::Hook::ViewListener
  def html_head(context=nil)
    if params[:hide_header]
      content_tag(:script, %Q{
        var old_unload = window.onload;
        window.onload = function() {
        ['uservoice-feedback-tab', 'header', 'navMenu', DigitalGazette.Sidebar.wrapper].each(function(el) {
          $(el).hide();
        });
        if(old_unload) old_unload();
        };
      })
      content_tag(:style, %Q{
        #uservoice-feedback { display:none !important; }
        #header { display:none !important; }
        #navMenu { display:none !important; }
        #dg_sidebar_wrapper { display:none !important; }
      })
    end
  end
end
