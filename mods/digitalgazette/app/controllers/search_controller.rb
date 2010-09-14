class SearchController < ApplicationController

  prepend_before_filter :prefix_path
  helper_method :list_partial

  include SearchHelper

  # GET /search
  # TODO move @dom_id and @partial out of the controller logic some day
  def index
    @preferred = @path.arg_for("preferred")
    if request.post?
      # form was POSTed with search query
      # let's redirect to nice GET search url like /me/search/text/abracadabra/person/2
      redirect_to_search_results
    else
      #debugger
      render_search_results
    end
  end

  
  def paginate_panel
    # what do we do, if we have no items in one box, but many on others

    # get params[:panel_page]
    panel_page = params[:panel_page]
    # create a storage for the multi-widget-pagination
    @widget_pages = params[:widget_pages]
    # get the widgets that are currently active
    get_page_types    
    # now collect the pages per page - type
    #
    # we get the request via xhr
    # and so we select the current - widget - page and path for the pagination from the dom
    with_options_for_widget do |options|
      render_search_results
    end
  end
  
  # returns the right widget_options to build the query
  def widget_options(page_type)
  end
  
  def render_search_results
    @path.default_sort('updated_at') if @path.search_text.empty?
    get_options # @page_type @page_types @dom_id @widget @wrapper @tags
    get_pages # @pages

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

    if request.xhr?
      # TODO clean up this logic, to make it easier to use different partials
      # list_partial = @page_type == 'OverlayPage' ? 'overlays/list' : 'pages/list'
      render :update do |page|
        page[@dom_id].replace_html :partial => list_partial, :locals => { :pages => @pages, :title => I18n.t("page_search_title".to_sym, :type => I18n.t(:"dg_#{@dom_id}")), :no_top_pagination => true}
      end
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
  #   debugger
  # end

  # add to the path
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

  # TODO somewhere else, more general
  def list_partial
    if @widget
      BOX_PARTIALS[@widget.to_s] || raise("you called an illegal widget #{@widget.to_s}")
    elsif @page_type
      PAGE_TYPE_PARTIALS[@page_type.to_s] || raise("you called an illegal partial #{@page_type.to_s}")
    elsif @wrapper
      LEGAL_PARTIALS.include?(@wrapper) ? @wrapper : raise("you called an illegal partial #{@wrapper.to_s}")
    end

  end

  # retrieve all options, we need to build a proper UI
  def get_options
    get_page_types
    @widget = params[:widget]
    @wrapper = params[:wrapper]
    @dom_id = get_dom_id    
    @tags = @path.args_for("tag")
  end

  # create an id for the container we want to update in
  # if @wrapper is set, then the id's are built like this:
  #
  # sidebar_wiki_page_list
  def get_dom_id
    return params[:dom_id] if params[:dom_id]
    base_name =  @page_type ? @page_type.underscore+"_list" : "pages_list"
    ret = "#{@wrapper+'_' if @wrapper}#{base_name}" 
  end

  # retrieve all page types in the current focus
  def get_page_types
    @page_types =  [@path.args_for("type")].flatten.compact.select{ |t|
      t != "type" && SEARCHABLE_PAGE_TYPES.include?(t)}
    @page_types = SEARCHABLE_PAGE_TYPES if @page_types.empty?
    @page_type = @page_types.first if @page_types.size == 1
  end

  # retrieve all pages
  def get_pages
    # if no explicit pagetype is set, we want to search in all searchable page types
    if @page_type
      if EXTERNAL_PAGE_TYPES.include?(@page_type)
        @pages = get_external_results
      else
        @pages = Page.paginate_by_path(@path, options_for_me({:method => :sphinx}.merge(pagination_params.merge({ :per_page => 2}))))
      end
    else
      @path = PathFinder::ParsedPath.new((@path + default_page_types_path).to_param) unless @path.arg_for('type')
      @pages = Page.paginate_by_path(@path, options_for_me({:method => :sphinx}.merge(pagination_params.merge({ :per_page => 2}))))
    end
  end

  # TODO think about doing this with path finder internals
  def default_page_types_path
    merge_path = []
    (SEARCHABLE_PAGE_TYPES - EXTERNAL_PAGE_TYPES).each do |page_type|
      merge_path << "type/#{page_type}"
    end
    PathFinder::ParsedPath.new(merge_path.join('/or/'))
  end

  # mix in instance variables from the external api
  def get_external_results
    if @tags
      Geocommons::Overlay.paginate_by_tag(@tags, pagination_params)
    else
      Geocommons::Overlay.paginate({:query => @path.arg_for("text")}.merge!(pagination_params.merge!(:per_page => 2)))
    end
  end

end
