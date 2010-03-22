class ModSettingsListener < Crabgrass::Hook::ViewListener
  def admin_nav(context)
    content_tag(:ul, content_tag(:li, link_to("Plugin Settings", admin_mod_settings_url)))
  end
end
