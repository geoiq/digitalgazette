module RootHelper
  def titlebox_description_html
    if logged_in?
      @group.profiles.public.summary_html
    else
      welcome = I18n.t(:welcome_title, :site_title => current_site.title)
      message = first_with_any(I18n.t(:welcome_login_message), I18n.t(:welcome_message))
      content_tag(:h1, welcome) <<
        format_text(message)
    end
  end

  def sidebar_top_partial
    if logged_in?
      'sidebox_top'
    else
      '/account/login_form_box'
    end
  end
end
