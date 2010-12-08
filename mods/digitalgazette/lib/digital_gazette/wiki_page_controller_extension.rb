module DigitalGazette
  module WikiPageControllerExtension
    include DigitalGazette::HtmlToPdf
    include DigitalGazette::HtmlToRtf

    def pdf
      send_data(html_to_pdf(html_for_export), :type => "application/pdf", :filename => "#{@page.name}.pdf")
    end

    def rtf
      send_data(html_to_rtf(html_for_export), :type => "application/rtf", :filename => "#{@page.name}.rtf")
    end

    protected

    def html_for_export
      render_to_string(:template => "wiki_page/print", :layout => "printer-friendly")
    end
  end
end
