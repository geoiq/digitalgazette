module SearchHelper

  
  PATHS_FOR_BOXES = 
    
    { :most_viewed => [["most_viewed"],["limit","5"]],
      :recent => [["limit","5"],["ascending","created_at"]]
  
  }.freeze
  
  # wraps certain widgets into a box
  def box_for type, options={}
    page_types = options[:page_types] || ['wiki']
    options[:path] = PATHS_FOR_BOXES[type.to_sym]
    options[:dom_id] = type.to_s
    options[:widget] = type.to_s
    ret = ""
    ret << content_tag(:div, :id => type.to_s, :class => 'roundTop txtDarkGrey') do
      content_tag(:strong) { I18n.t(:dg_box_title, :type => type)}
    end
    ret << content_tag(:div, :class => 'subPageRightLinks') do
      content_tag(:ul, :class => "dynamicLinkList") do
        widgets_for(page_types, options)
      end
    end  
  end
  
  # :per_page => nil  - no pagination
  # :per_page => 3    - pagination (3 per page)
  # TODO create default behaviour (list partial) for non js
  def widget_for page_type, options={}
    options = options_for_widget(page_type,options)
    widget_id = "#{page_type}_page_list"
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
    { :page_type => page_type}.merge(options)
  end

end
