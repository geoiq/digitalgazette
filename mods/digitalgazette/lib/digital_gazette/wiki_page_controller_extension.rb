module DigitalGazette
  module WikiPageControllerExtension
    def self.included(base)
      base.class_eval do
        alias_method_chain :login_or_public_page_required, :digital_gazette
      end
    end

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

    # don't require a login for public pages
    # (overriding BasePageController)
    def login_or_public_page_required_with_digital_gazette
      if %w(show print pdf rtf).include?(action_name) and @page and @page.public?
        true
      else
        return login_required
      end
    end
  end
end
