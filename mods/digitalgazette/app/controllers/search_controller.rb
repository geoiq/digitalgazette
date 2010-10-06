class SearchController < ApplicationController

  prepend_before_filter :prefix_path
  helper_method :list_partial
  helper_method :get_dom_id_for
  helper_method :list_partial_for

  include SearchHelper

  # GET /search
  # TODO move @dom_id and @partial out of the controller logic some day
  def index
    @path = parse_filter_path(params[:search]) if @path.empty?
    if params[:limit]
      @path.merge!(['limit', params[:limit]])
    end
    @preferred = @path.arg_for("preferred")
    if request.post?
      # form was POSTed with search query
      # let's redirect to nice GET search url like /me/search/text/abracadabra/person/2
      redirect_to_search_results
    else

      render_search_results # if request.xhr?
    end
  end


  def render_search_results
    @path.default_sort('updated_at') if @path.search_text.empty?
    get_options # @page_type @page_types @dom_id @widget @wrapper @tags @panel
    # in digitalgazette we fetch all pages via xhr, this way we do not want to render search results if its non-xhr
    get_pages if request.xhr? # @pages

    #FIXME this won't happen, we have no @pages anymore
    # if there was a text string in the search, generate extracts for the results
    if @path.search_text and @pages.any?
      begin
        add_excerpts_to_pages(@pages)
      rescue Errno::ECONNREFUSED, Riddle::VersionError, Riddle::ResponseError => err
        RAILS_DEFAULT_LOGGER.warn "failed to extract keywords from sphinx search: #{err}."
      end
    end

    full_url = search_url + @path
    handle_rss(:title => full_url, :link => full_url,
               :image => (@user ? avatar_url(:id => @user.avatar_id||0, :size => 'huge') : nil))


    unless send_pages! # send the pages to the browser
      # museum during refactoring
     # if request.xhr?
     #
     #
     # NOTE this would be the place for a fallback
     #   render :update do |page|
     #     page[@dom_id].replace_html :partial => list_partial, :locals => { :pages => @pages, :title => I18n.t("page_search_title".to_sym, :type => I18n.t(:"dg_#{@dom_id}")), :no_top_pagination => true}
     #   end
     # end

    end
  end


  # separate by page types into instance variables
  # NOTE not used anymore, because we get the pages each via ajax
  # def split_by_page_types
  #   @grouped_pages = @pages.group_by{ |page| page.class.name}
  #   # splitting grouped pages into it's own instance variables
  #   SEARCHABLE_PAGE_TYPES.each do |t|
  #     instance_variable_set(:"@#{t.underscore.pluralize}",@grouped_pages[t])
  #   end
  # end

  # retrieve all pages
  def get_pages
    setup_page_store #setup the page store to store the pages -> ui - configuration
    # if no explicit pagetype is set, we want to search in all searchable page types

   # if ! @page_type # if @page_type is set, we only need to save @pages = @page_type.constantize.find ....

      # separate the page_types by the condition wether
      # a) they are internal, means Crabgrass::Page or
      # b) external, means Crabgrass::ExternalPage
      @page_type_groups = @page_types.group_by {|page_type|
        EXTERNAL_PAGE_TYPES.include?(page_type) ? :external : :internal}.to_hash # group the external and internal pages


      # Process internal Pages
      @naked_path = @path.dup.remove_keyword("type")
      # Create the path for the internal resources
      # @internal_path = @naked_path.dup.add_types!(@page_type_groups[:internal]).sort!
      # TODO this does not work as we want
      #
      # Benchmarks: OPTIMIZE use Union, i am running out of time.
      #
      # >> Benchmark.measure {1000.times{Page.find_by_sql("(SELECT * FROM pages where pages.type = 'AssetPage' LIMIT 1)"); Page.find_by_sql("SELECT * FROM pages where pages.type = 'WikiPage' LIMIT 1")}}
#=> #<Benchmark::Tms:0x7f86d9ddddc8 @total=1.52, @utime=1.47, @cstime=0.0, @cutime=0.0, @label="", @stime=0.05000#00000000003, @real=1.59843301773071>
#>>
  #     >> Benchmark.measure {1000.times{Page.find_by_sql("(SELECT * FROM pages where pages.type = 'AssetPage' LIMIT 1) UNION (SELECT * FROM pages where pages.type = 'WikiPage' LIMIT 1)")}}
# => #<Benchmark::Tms:0x7f86d98bcdd0 @total=0.909999999999999, @utime=0.859999999999999, @cstime=0.0, @cutime=0.0, @label="", @stime=0.0499999999999998, @real=0.917029857635498>
      #
      #
      # We want e.g. WHERE pages.type = wiki OR pages.type = asset
      # but we want the same limit per page for every model - figure out, how to do this best
      # NOTE maybe Crabgras internals could also deal with external pages already and just skip them
  
     # creates the hash of @internal_pages
      # and decorates it with the corresponding results from the query
      @internal_pages = { }
      @page_type_groups[:internal].each do |page_type|
        @internal_pages[page_type] ||={}
        @internal_pages[page_type][:pages] = Page.paginate_by_path(@naked_path.add_types!(page_type.to_a), options_for_me({:method => :sphinx}.merge(pagination_params.merge({ :per_page => get_per_page, :page => (params[:page] || 1)})))) # order in the path is important
        @internal_pages[page_type][:dom_id] = get_dom_id_for(page_type)
      end

      # Create the path for the external resources
      # TODO implement some logic, that groups the external resources
      # by their source
      # this requires, that every source returns a collection, that
      # lets us determine the Resource -Type (PageType) for every entry in the collection
      @external_pages = {}
      @page_type_groups[:external].each do |page_type|
        @external_pages[page_type] =
        { :pages => Crabgrass::ExternalPathFinder.paginate(page_type,@naked_path, pagination_params.merge({ :per_page => get_per_page, :page => (params[:page] || 1)})),
          :dom_id => get_dom_id_for(page_type)}
          #debugger
          # sketches
          #Crabgrass::ExternalApi.for(page_type).model.call(:paginate, @external_path, { :page => params[:page], :per_page => get_per_page})
          #Api.for(page_type).method(:paginate).call(@external_path, params[:page])
      end
      @page_store = @page_store.merge(@external_pages).merge(@internal_pages)
    # TODO create WillPaginate::Collection
      # NOTE this is the place, where the full WidgetTree
      # would be available
      #
      # try something like @pages.to_json


  end


  # general update method
  # sends the right partials to the browser
  # therefore takes the Hash in @pages an resolves it
  # to the pages/list or the widget/panel - specific partials
  #
  # TODO implement non-xhr fallback by passing
  #      the relevant widget-tree
  #      down to clever partials/helpers
  #
  def send_pages!
    if request.xhr?
     # Update every widget as one, if existing
      render :update do |page|
        @page_store.to_hash.each_pair do |page_type,options|
          dom_id = options[:dom_id]
          pages = options[:pages]
          page[dom_id].replace_html(:partial => (partial = list_partial_for(:page_type => page_type)),
                                    :locals => {
                                      :pages => pages,
                                      :title => I18n.t("page_search_title".to_sym,
                                                       :type => I18n.t("dg_#{page_type}".to_sym)),
                                      :no_top_pagination => true
                                    } )
          page[dom_id].insert( { :after => panel_pagination_at(:bottom, options)})
          logger.debug("REPLACING '#{dom_id}' WITH PARTIAL '#{partial}'. HAVE #{pages.size} PAGES OF TYPE '#{page_type}'. CURRENT PAGE #{params[:page].inspect} PER PAGE #{params[:per_page].inspect}")
        end
        if @panel && params[:pagination]
          page["#{@panel}_pagination_bottom"].replace_html(panel_pagination_at(:bottom, { :pagination => params[:pagination], :path => @path.to_param}))
        end
      end
    end
  end


  
  #
  #
  # OPTIONS & FILTERS
  #
  

  
  # add to the path
  # NOTE deprecated
  def prefix_path
    path = []
    if params[:page_type]
      [params[:page_type]].flatten.each do |type|
        path << "type"
        path << type
      end
      @path.merge!(path)
    end
  end

  # same as list_partial
  # but used for iterative partial resolving of a group of page types
  def list_partial_for(options={ })
    ret =
    if  options[:wrapper] ||= @wrapper
       LEGAL_PARTIALS[options[:wrapper].to_s]
    elsif options[:widget] ||= @widget
      BOX_PARTIALS[options[:widget].to_s] || ""
    elsif options[:page_type] ||= @page_type
      PAGE_TYPE_PARTIALS[options[:page_type].to_s] || ""
    end
    logger.debug("fallback to 'pages/list'") unless ret
    ret = "pages/list" if (ret.nil? || ret.empty?)
    logger.debug "chose #{ret.to_s} for #{options.inspect}"
    ret
  end

  # TODO somewhere else, more general
  # determines the right list partial
  #
  # when there is a @widget recognized
  # it takes the configured BOX_PARTIAL for that widget
  #
  # when there is ONE SINGLE @page_type
  # (NOTE that means somehow 'pages/list')
  # it renders the corresponding partial
  #
  # and when there is a @wraper
  #
  # it uses it as partial if it is legal
  def list_partial
    if @wrapper
      if LEGAL_PARTIALS.keys.include?(@wrapper)
        LEGAL_PARTIALS[@wrapper]
      elsif LEGAL_PARTIALS.values.include?(@wrapper)
        LEGAL_PARTIALS.values[LEGAL_PARTIALS.values.index(@wrapper)]
      else
        raise("you called an illegal partial #{@wrapper.to_s}")
      end
    elsif @widget
      BOX_PARTIALS[@widget.to_s] || raise("you called an illegal widget #{@widget.to_s}")
    elsif @page_type
      PAGE_TYPE_PARTIALS[@page_type.to_s] || raise("you called an illegal partial #{@page_type.to_s}")
    end

  end

  # retrieve all options, we need to build a proper UI
  def get_options
    get_page_types

    @dom_id = get_dom_id # our default dom_id
    # TODO create possibility to pass cascaded widgets
    @widget = params[:widget] #is there a widget specified
    # a wrapping partial
    @wrapper = params[:wrapper]
    # a panel has a container and this container should be updated with the whole response
    # NOTE i am not really sure if we need this
    @panel = params[:panel]

    @tags = @path.args_for("tag")
    @namespace = params[:namespace]
  end

  # TODO make this more flexible
  #      to update several panels at a time
  #      you need more than the instance variables @dom_id, @widget and so
  #
  #      write something like Widget.new() and
  #      pass configuration from the params
  #      User or internal configuration
  def get_dom_id_for(page_type, options={ })
    get_dom_id(page_type,options={ })
  end

  # create an id for the container we want to update in
  def get_dom_id(page_type = nil, options = { })
    return params[:dom_id] if params[:dom_id]
    page_type ||= @page_type
    prefix = (@panel && !@panel.empty?) ? "#{@panel}_" : ""
    #prefix << "#{@widget}_" if @widget && !@widget.empty?
    prefix << (page_type ? page_type.underscore+"_list" : "pages_list")
    # FIXME in case of 'pages_list', and we have more than one page type,
    # we will get chaos or should use an appending technique

  end

  # retrieve all page types in the current focus
  def get_page_types
    @page_types =  [@path.all_args_for("type")].flatten.compact.select{ |t|
      t != "type" && SEARCHABLE_PAGE_TYPES.include?(t)}
    @page_types = SEARCHABLE_PAGE_TYPES if @page_types.empty?
    @page_type = @page_types.first if @page_types.size == 1
  end

  

  # the @page_store is our widget tree
  def setup_page_store
    @page_store = {}
  end


  # default for per page or something more complex
  def get_per_page
    (@path.keywords.include?('limit') ? @path.arg_for('limit') : (params[:per_page] || 2))
  end

  #
  # access to external_results
  # NOTE this method is somehow deprecated
  # and only used in fallbacks ?
  #
  def get_external_results(page_type=nil)
    page_type ||= @page_type
    raise "no page type specified to retrieve external results" unless(page_type)
    Crabgrass::ExternalPathFinder.find(page_type,@path)
  end


end

