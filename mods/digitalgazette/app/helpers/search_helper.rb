
module SearchHelper


  PATHS_FOR_BOXES =
    { :most_viewed => [["most_viewed"],["limit","5"]],
      :recent => [["limit","5"],["ascending","created_at"]]}.freeze

  # wraps certain widgets into a box
  def box_for box_type, options={}
    page_type = options[:page_type]
    options[:path] = PATHS_FOR_BOXES[box_type.to_sym]
    options[:dom_id] = box_type.to_s
    options[:widget] = box_type.to_s
    ret = ""
    ret << content_tag(:div, :id => box_type.to_s, :class => 'roundTop txtDarkGrey') do
      content_tag(:strong) { I18n.t(:dg_box_title, :type => box_type)}
    end
    ret << content_tag(:div, :class => 'subPageRightLinks') do
      content_tag(:ul, :class => "dynamicLinkList") do
        widget_for(page_type, options)
      end
    end
  end

  # :per_page => nil  - no pagination
  # :per_page => 3    - pagination (3 per page)
  # TODO create default behaviour (list partial) for non js
  def widget_for page_type, options={}
    options = options_for_widget(page_type, options)
    widget_id = options[:dom_id] || "#{page_type}_page_list"
    ret = ""
    ret << content_tag(:div, :id => widget_id) do
      javascript_tag(remote_function({ :url => search_url(options), :method => 'get'}))+spinner(widget_id, :show => true)
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

  def options_for_widget(page_type, options)
    {:page_type => page_type }.merge(options)
  end

end
