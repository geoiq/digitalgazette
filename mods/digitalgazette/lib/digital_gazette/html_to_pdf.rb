require 'open3'
module DigitalGazette::HtmlToPdf
  protected

  def html_to_pdf(html_source, option_string="")
    pdf = nil
    Open3.popen3(wkhtmltopdf(option_string)) do |stdin, stdout, stderr|
      stdin.write(html_source)
      stdin.close
      pdf = stdout.read
    end
    return pdf
  end

  private

  def wkhtmltopdf(option_string='')
    path = `which wkhtmltopdf`.strip
    raise "wkhtmltopdf missing! Can't generate PDF" if path.empty?
    return "#{path} #{option_string} - -"
  end
end
