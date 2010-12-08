require 'open3'
module DigitalGazette::HtmlToRtf
  protected

  def html_to_rtf(html_source)
    rtf = nil
    Open3.popen3(`which perl`) do |stdin, stdout, stderr|
      stdin.write %Q{
        use HTML::FormatRTF;
        print HTML::FormatRTF->format_string("#{perl_escape(html_source)}");
      }
      stdin.close
      rtf = stdout.read
      failures = stderr.read
      if failures.strip.any?
        raise "Failed to convert HTML to RTF. Make sure to have 'libhtml-format-perl' installed (and a working perl installation). Errors received from perl were: #{failures.inspect}."
      end
    end
    return rtf
  end

  private

  def perl_escape(string)
    string.gsub('"', "\\\"")
  end
end
