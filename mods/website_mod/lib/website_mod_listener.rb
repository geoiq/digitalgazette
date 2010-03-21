class WebsiteModListener < Crabgrass::Hook::ViewListener
  def html_head(context={})
    stylesheet_link_tag('website_mod', :plugin => 'website_mod')
  end
end
