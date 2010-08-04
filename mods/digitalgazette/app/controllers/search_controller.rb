
class SearchController < ApplicationController

  prepend_before_filter :prefix_path
  helper_method :list_partial

  # TODO move all this into Conf
  SEARCHABLE_PAGE_TYPES = ["wiki","asset","map","overlay"].freeze
  EXTERNAL_PAGE_TYPES = ["Overlay"].freeze
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


  # GET /search
  # TODO move @dom_id and @partial out of the controller logic some day
  def index
    if request.post?
      # form was POSTed with search query
      # let's redirect to nice GET search url like /me/search/text/abracadabra/person/2
      redirect_to_search_results
    else
      render_search_results
    end
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
        page[@dom_id].replace_html :partial => list_partial, :locals => { :pages => @pages, :title => I18n.t("page_search_title".to_sym, :type => I18n.t(:"dg_#{@dom_id}"))}
      end
    end

  end


  # mix in instance variables from the external api
  def get_external_results
    if @tags
      Geocommons::RestAPI::Overlay.paginate_by_tag(*@tags)
    else
       Geocommons::RestAPI::Overlay.paginate(:query => @path.arg_for("text"))
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


  # NOTE not used anymore
  # # TODO think about doing this with path finder internals
  # def merge_default_path
  #   merge_path = (["type"] << SEARCHABLE_PAGE_TYPES.map(&:underscore).join("/or/type")).flatten.join('/')
  #   @path.merge!(merge_path) unless @path.first_arg_for("type")
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
    @dom_id = get_dom_id
    @widget = params[:widget]
    @wrapper = params[:wrapper]
    @tags = @path.args_for("tag")
  end

  # create an id for the container we want to update in
  def get_dom_id
    return params[:dom_id] if params[:dom_id]
    @page_type ? @page_type.underscore+"_list" : "pages_list"
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
    @pages = []
    @page_types.each do |page_type|
      if EXTERNAL_PAGE_TYPES.include?(page_type)
        @pages << get_external_results
      else
        @pages = Page.paginate_by_path(@path, options_for_me({:method => :sphinx}.merge(pagination_params.merge({ :per_page => 2}))))
      end
    end
  end
end
