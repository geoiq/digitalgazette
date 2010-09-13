module DigitalGazette
  module LayoutHelperExtension
    def custom_masthead_site_title
      content_tag :h2, link_to(current_site.title, '/')
    end

    def masthead_container
      locals = {}
      appearance = current_site.custom_appearance
      if appearance and appearance.masthead_asset and current_site.custom_appearance.masthead_enabled
        height = appearance.masthead_asset.height
        bgcolor = (appearance.masthead_background_parameter == 'white') ? '' : '#'
        bgcolor = bgcolor+appearance.masthead_background_parameter
        locals[:section_style] = "height: #{height}px"
        locals[:style] = "background-repeat: no-repeat; background-image: url(#{appearance.masthead_asset.url}); height: #{height}px;"
        locals[:render_title] = false
      else
        locals[:section_style] = ''
        locals[:style] = ''
        locals[:render_title] = true
      end
      render :partial => 'layouts/base/masthead', :locals => locals
    end

  end
end
