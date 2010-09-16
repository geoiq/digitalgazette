
module SearchHelper

  # wraps certain widgets into a box
  def box_for box_type, options={}
    page_type = options[:page_type]
    options[:path] = PATHS_FOR_BOXES[box_type.to_sym]
    options[:dom_id] = box_type.to_s
    options[:widget] = box_type.to_s
    ret = ""
    # box title
    ret << content_tag(:div, :class => 'roundTop txtDrkGray') do
      content_tag(:strong) { I18n.t(:dg_box_title, :type => I18n.t("dg_#{box_type}".to_sym))}
    end
    # box content
    ret << content_tag(:div, :class => 'subPageRightLinks', :id => box_type.to_s) do
      content_tag(:ul, :class => "dynamicLinkList") do
        widget_for(page_type, options)
      end
    end
    # box footer
    ret << content_tag(:div, :class => 'roundBtm') do
    end
  end

  # returns widgets in the order implied by the current preffered page type
  def dynamic_widgets preferred
    page_types = SEARCHABLE_PAGE_TYPES.include?(preferred) ? [preferred] : []
    page_types << SEARCHABLE_PAGE_TYPES
    page_types = page_types.flatten.compact.uniq
    widgets_for page_types
  end


  # :per_page => nil  - no pagination
  # :per_page => 3    - pagination (3 per page)
  # TODO create default behaviour (list partial) for non js
  def widget_for page_type, options={}
    options = options_for_widget(page_type, options)
    widget_id = options[:dom_id] || "#{page_type}_list"
    @path = @path.remove_keyword("type") if page_type
    path = @path.to_param
    ret = ""
    ret << content_tag(:div, :id => widget_id) do
      # @path.set_keyword('type', options[:page_type])
      javascript_tag(remote_function({ :url => search_url(:path => path), :method => 'get', :with => "'#{options.to_param}'"}))+spinner(widget_id, :show => true)
    end
    ret
  end

  def widgets_for args, options={ }
    ret = ""
    args.each do |arg|
      ret << widget_for(arg,options)
    end
    ret
  end

  def options_for_widget(page_type, options)
    page_type ? {:page_type => page_type }.merge!(options) : options
  end

  # returns the search banner and header for given page type
  def banner_and_header_for page_type
    if HEADERS_FOR_PAGE_TYPES[page_type]
      ret = ""
      ret << render(:partial => "pages/#{page_type.underscore}/header")
      ret << render(:partial => 'search/banner', :locals => { :page_type => page_type })
      ret << content_tag(:div, :id => 'browse') do
        content_tag(:h4, I18n.t("browse_#{page_type}".to_sym))
      end
      ret
    else
      content_tag(:div, :class => 'pageTitle') do
        content_tag(:h2, I18n.t(:dg_search_header))
      end
    end
  end
end