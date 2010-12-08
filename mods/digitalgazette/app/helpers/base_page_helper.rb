module BasePageHelper
  # using the page_sidebar_actions hook didn't work...
  def export_line
    if @page.kind_of?(WikiPage)
      export_pdf = link_to(I18n.t(:wiki_pdf_link), page_url(@page, :action => "pdf"))
      content_tag :li, export_pdf, :class => 'small_icon mime_pdf_16'
    end
  end
end
