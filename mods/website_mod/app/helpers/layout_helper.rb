module LayoutHelper

  ##
  ## CUSTOMIZED STUFF
  ##
  def navbar
    return '' unless current_site
    content_tag(:ul, render(:partial => 'root/navbar_item', :collection => current_site.network.menu_items), :class => 'navbar')
  end

  # build a masthead, using a custom image if available
  def custom_masthead_site_title
    appearance = current_site.custom_appearance
    if appearance and appearance.masthead_asset
      # use an image
      content_tag :div, :id => 'site_logo_wrapper' do
        navbar+
        content_tag(:a, :href => '/', :alt => current_site.title) do
          image_tag(appearance.masthead_asset.url, :id => 'site_logo')
        end
      end
    else
      # no image
      content_tag :h1, current_site.title, :id => 'site_title'
      # <h1 id='site_title'><%= current_site.title %></h1>
    end
  end

end
