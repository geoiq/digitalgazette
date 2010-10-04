require 'will_paginate/collection'
module SearchHelper


  # EXAMPLE Widget configuration
  # TODO make widgets globally configured,
  # that takes the pressure from the methods
  #
  #
  #
  # define_widget :title do |widget|
  #   widget.set_title :other_title
  #   widget.wrapper "funky_title"
  #   widget.box true
  #   widget.pagination :all
  #
  # TODO create a full litle system, that includes the constants now stored in lib/../better_configuration
  #
  #


  # NOTE we could use it for every page list
  # but we only need it if we want to loa
  #
  # provides a panel for more than one widget
  # for more than one pagetypes
  #
  # adds pagination for the whole panel
  #
  # last argument can be an options hash:
  #
  # - box (default: false) # renders a box or not
  # - page_types # optional, what page_type should be used here
  # - pagination :all, :top, :bottom or nil
  # -
  def panel name, options={}, &block
    options.merge!({ :for => :all, :box => false, :pagination => :bottom})
    ret = ""

    content = capture(&block)

    # version with blocks
    # if options[:wrapper]
    #   concat(render(:partial => LEGAL_PARTIALS[options[:wrapper]]), block.binding)
    # else
    #   concat(content_tag(:div, :id => options[:id], :class => options[:class]), block.binding)
    # end

    # version with locals
    options[:id] ||= name.to_s
    if options[:wrapper]
      concat(render(:partial => list_partial_for(options),  :locals => { :content => content }), block.binding)
    else
      concat(content_tag(:div, :id => options[:id], :class => options[:class], &block), block.binding)
    end
  end

  def panel_pagination_at position, options, *args
    if options[:pagination] && (options[:pagination] == :all || options[:pagination] == position.to_sym)
      pagination_links_for_widgets(args)
    end
  end

  # takes more than one widget and provides
  # pagination links that reload the index
  # action providing a screen with widgets for
  # all pagetypes
  def pagination_links_for_widgets(widgets)
    collection = WillPaginate::Collection.create((params[:page]||1),10,200) do |pager|
      "#TODO"
    end
    pagination_links(collection)
  end


  # wraps one into a box
  def box_for box_type, options={}
    page_type = options[:page_type]
    page_types = options[:page_types]
    #
    options[:path] = PATHS_FOR_BOXES[box_type.to_sym]
#   options[:dom_id] = box_type.to_s
    options[:widget] = box_type.to_s
    options[:wrapper] = "pages_box" # FIXME this should not be hardcoded?

    options[:autoload] ||= true #NOTE boxes are autoloaded see widget_for
    ret = ""
    # box title
    ret << content_tag(:div, :class => 'roundTop txtDrkGray') do
      content_tag(:strong) { I18n.t(:dg_box_title, :type => I18n.t("dg_#{box_type}".to_sym))}
    end
#    debugger
    # box content
    ret << content_tag(:div, :class => 'subPageRightLinks', :id => box_type.to_s) do
      content_tag(:ul, :class => "dynamicLinkList") do
        if page_type
          widget_for(page_type, options)
        elsif page_types
          widgets_for(page_types,options)
        end
      end
    end
    # box footer
    ret << content_tag(:div, :class => 'roundBtm') do
    end
  end

  # returns widgets in the order implied by the current preffered page type
  def dynamic_widgets preferred, options={ }
    page_types = SEARCHABLE_PAGE_TYPES.include?(preferred) ? [preferred] : []
    page_types << SEARCHABLE_PAGE_TYPES
    page_types = page_types.flatten.compact.uniq
    widgets_for page_types, options
  end





  # :per_page => nil  - no pagination
  # :per_page => 3    - pagination (3 per page)
  # TODO create default behaviour (list partial) for non js
  # :dom_id           - save explicit dom-id
  # :autoload => 'when true, then adds a remote call to get the items'
  def widget_for page_type, options={}
    debugger
    options = options_for_widget(page_type, options)
    widget_id = id_for_widget(page_type,options)
    @path = @path.remove_keyword("type") if page_type
    autoload = options[:autoload] # TODO add remote call then
    path = @path
    raise "INVALID WIDGET ID: #{widget_id.inspect} (for page type: #{page_type.inspect})" unless widget_id && widget_id.any? # :)
    content_tag(:div, (autoload ? spinner(widget_id, :show => true) : ''), :id => widget_id) +
      (autoload ? javascript_tag(remote_function({ :url => search_url(:path => path), :method => 'get', :with => "'#{options.to_param}'"})) : '')
  end


  def id_for_widget(page_type,options)
    str = options[:dom_id] || "#{page_type}_list"
   options[:panel] ? "#{options[:panel]}_#{str}" : str
  end

  def widgets_for args, options={ }
    ret = ""
    if args == :all
      args = SEARCHABLE_PAGE_TYPES
    end
    options = { :panel => @panel, :widget => @widget, :wrapper => @wrapper}.merge(options)
    args.each do |arg|
      ret << widget_for(arg,{ :autoload => false}.merge(options))
    end
    path = @path.dup.remove_keyword("type")
    path.add_types! args
    ret << javascript_tag(remote_function({ :url => search_url(:path => path), :method => 'get', :with => "'#{options.to_param}'"}))#+spinner(@panel, :show => true)

    ret
  end

  def options_for_widget(page_type, options)
    options = page_type ? {:page_type => page_type}.merge!(options) : options
    options = options.merge({ :page => params[:page]}) if params[:page]
    options = options.merge({ :per_page => params[:per_page]}) if params[:per_page]
    options
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
