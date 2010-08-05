
module SearchHelper


  #
  # Configuration over convention :)
  # NOTE this will help us to make this behaviour easier enabled
  # and configured in mods / sites TODO put it into Conf.


  PATHS_FOR_BOXES =
    { :most_viewed => [["most_viewed"],["limit",5]],
      :recent => [["limit",5],["ascending","created_at"]]}.freeze

  HEADERS_FOR_PAGE_TYPES = {
    "wiki" => true,
    "asset" => true,
  }

  # TODO move all this into Conf
  SEARCHABLE_PAGE_TYPES = ["wiki","asset","map","overlay"].freeze

  EXTERNAL_PAGE_TYPES = ["overlay"].freeze

  LEGAL_PARTIALS = ["pages/list","overlays/list","pages/box"].freeze

  PAGE_TYPE_PARTIALS = {
    "wiki" => "pages/list",
    "asset" => "pages/list",
    "map" => "pages/list",
    "overlay" => "overlays/list"
  }.freeze

  BOX_PARTIALS = {
    "recent" => "pages/box",
    "most_viewed" => "pages/box"
  }.freeze


  # wraps certain widgets into a box
  def box_for box_type, options={}
    page_type = options[:page_type]
    options[:path] = PATHS_FOR_BOXES[box_type.to_sym]
    options[:dom_id] = box_type.to_s
    options[:widget] = box_type.to_s
    ret = ""
    ret << content_tag(:div, :class => 'roundTop txtDarkGrey') do
      content_tag(:strong) { I18n.t(:dg_box_title, :type => box_type)} +
      content_tag(:div, :class => 'subPageRightLinks', :id => box_type.to_s) do
        content_tag(:ul, :class => "dynamicLinkList") do
          widget_for(page_type, options)
        end
      end
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
    ret = ""
    ret << content_tag(:div, :id => widget_id) do
      javascript_tag(remote_function({ :url => search_url, :method => 'get', :with => "'#{options.to_param}'"}))+spinner(widget_id, :show => true)
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

  def banner_and_header_for page_type
    if HEADERS_FOR_PAGE_TYPES[page_type]
      ret = ""
      ret << render(:partial => "pages/#{page_type.underscore}/header")
      ret << render(:partial => 'search/banner', :locals => { :page_type => page_type })
      ret
    end
  end
end
