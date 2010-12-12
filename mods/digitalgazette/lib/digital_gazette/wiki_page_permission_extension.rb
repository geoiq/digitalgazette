module DigitalGazette::WikiPagePermissionExtension
  def may_pdf_wiki_page?(page=@page)
    raise 'pdf'
    may_show_wiki_page?(page)
  end

  def may_rtf_wiki_page?(page=@page)
    raise 'rtf'
    may_show_wiki_page?(page)
  end
end
