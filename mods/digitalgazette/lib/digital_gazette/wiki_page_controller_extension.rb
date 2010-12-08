module DigitalGazette
  module WikiPageControllerExtension
    include DigitalGazette::HtmlToPdf

    def pdf
      send_data(html_to_pdf(render_to_string(:template => "wiki_page/print", :layout => "printer-friendly")), :type => "application/pdf", :filename => "#{@page.name}.pdf")
    end
  end
end
