module LayoutHelper
   ##
  ## TITLE
  ##

  # note i guess we don't want the context right now, as everything is public
  def title_from_context
    context_title = case
                    when @page_type
                      @page_type.camelize
                    when @page
                      @page.title
                    else
                      I18n.t(:dg_search)
                    end
    "#{context_title} - #{current_site.title}"
  end

end
