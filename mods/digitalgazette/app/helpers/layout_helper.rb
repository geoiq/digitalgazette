module LayoutHelper
   ##
  ## TITLE
  ##

  # note i guess we don't want the context right now, as everything is public
  def title_from_context
    "#{(@page_type.camelize if @page_type) || I18n.t(:dg_search)} - #{current_site.title}"
    
  end

end
