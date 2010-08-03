module SearchHelper

  # :per_page => nil  - no pagination
  # :per_page => 3    - pagination (3 per page)
  # TODO create default behaviour (list partial) for non js
  def widget_for sym, options={}
    options = options_for_widget(sym,options)
    ret = ""
    ret << content_tag(:div, :id => "#{sym}_page_list") do
      javascript_tag(remote_function({ :url => search_url(options), :method => 'get'}))+"loading"
    end
    ret
  end

  def widgets_for *args
    options = args.pop if args.last.kind_of?(Hash)
    options ||= {}
    ret = ""
    args.each do |arg|
      ret << widget_for(arg,options)
    end
    ret
  end

  def options_for_widget(sym,options)
    { :page_type => sym}.merge(options)
  end

end
