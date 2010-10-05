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
    options = { :for => :all, :box => false, :pagination => :bottom}.merge(options)
    ret = ""
    ret << content_tag(:div, "", :id => "#{name}_pagination_top}") if options[:pagination] && options[:pagination].to_sym == :top

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
      ret = concat(render(:partial => list_partial_for(options),  :locals => { :content => content }))
    else
      ret = concat(content_tag(:div, :id => options[:id], :class => options[:class]){ content })
    end
    ret << content_tag(:div, "", :id => "#{name}_pagination_bottom") if options[:pagination] && options[:pagination].to_sym == :bottom
    ret
  end


  def panel_pagination_at position, options={ }
    if options[:pagination] && (options[:pagination] == :all || options[:pagination].to_sym == position.to_sym)
      options = { :page_links => false}.merge(options) # by default we don't show pagination links, because it's hard to calculate the total_pages for a whole panel with different types of resources
      pagination_links_for_widgets(options)
    end
  end

  # takes more than one widget and provides
  # pagination links that reload the index
  # action providing a screen with widgets for
  # all pagetypes
  def pagination_links_for_widgets(options={ })
    collection = WillPaginate::Collection.create((params[:page]||1),10,200) do |pager|
      "#TODO"
    end
    pagination_for(collection,options)
  end

  # wraps one or more widgets into a box
  # - options[:load] = false prevents panel from loading itself completlty. this should be the default behaviour when options[:autoload] is true
  # - options[:autoload] = false prevents each individual widget from loading itself. combined with options[:load] being false, nothing would be rendered at all
  def box_for box_type, options={}
    page_type = options[:page_type]
    page_types = options[:page_types]

    options[:path] = PATHS_FOR_BOXES[box_type.to_sym]
    options[:widget] = box_type.to_s
    options[:wrapper] ||= "pages_box" # FIXME this should not be hardcoded?
    options[:autoload] ||= true #NOTE boxes are autoloaded see widget_for
    ret = ""
    # box title
    ret << content_tag(:div, :class => 'roundTop txtDrkGray') do
      content_tag(:strong) { I18n.t(:dg_box_title, :type => I18n.t("dg_#{box_type}".to_sym))}
    end
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
    options = options_for_widget(page_type, options)
    widget_id = id_for_widget(page_type,options)
    @path = @path.remove_keyword("type") if page_type
    autoload = options[:autoload] # TODO add remote call then
    path = @path
    raise "INVALID WIDGET ID: #{widget_id.inspect} (for page type: #{page_type.inspect})" unless widget_id && widget_id.any? # :)
    ret = ""
    ret << content_tag(:div, (autoload ? spinner(widget_id, :show => true) : ''), :id => widget_id) +
      (autoload ? javascript_tag(remote_function({ :url => search_url(:path => path.to_param), :method => 'get', :with => "'#{options.to_param}'"})) : '')
    ret
  end

  def widgets_for args, options={ }
    logger.debug "#{args.inspect} #{options.inspect}"
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
    # we need to call options_for_widget, to merge with defaults, and pagination params. page type therewhile remains nil
    options = options_for_widget(nil, options)
    ret << javascript_tag(remote_function({ :url => search_url(:path => path.to_param), :method => 'get', :with => "'#{options.to_param}'"})) unless options[:load] == false
    ret
  end

  def options_for_widget(page_type, options)
    options = page_type ? {:page_type => page_type}.merge!(options) : options
    options = options.merge({ :page => (params[:page] || 1)})
    options = options.merge({ :per_page => (params[:per_page] || 2)}) #if params[:page]
    options
  end


  def sidebar_mini_search_text_field_tag
        text_field_tag('search[text]', '', :class => 'text',
                                      :size => 17,
                                      :value => I18n.t(:search_input_caption),
 #                                     :onkeypress => "this.form.submit();",
                                      :onfocus => hide_default_value,
                                      :onblur => show_default_value)
  end

  # returns a widgets id base ond page_type or options
  # returns the panels id if a options[:panel] is set
  def id_for_widget(page_type,options)
    str = options[:dom_id] || "#{page_type}_list"
    options[:panel] ? "#{options[:panel]}_#{str}" : str
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
