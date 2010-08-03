
class SearchController < ApplicationController

  prepend_before_filter :prefix_path

  # backed up from reports_controller.rb
  #     # @popular = Page.popular("AssetPage", 5)
  #     # @recent = Page.recent("AssetPage", 5)
  #     @popular = Page.find_by_path([['limit','5'], [ 'most_viewed', "5"], ['type', 'wiki_page']])
  #     @recent = Page.find_by_path([ ['limit','5'], [ 'ascending', 'created_at'], ['type', 'asset_page']])


  # TODO move all this into Conf
  SEARCHABLE_PAGE_TYPES = ["WikiPage","AssetPage","MapPage","Overlay"].freeze
  EXTERNAL_PAGE_TYPES = ["Overlay"].freeze
  PAGE_TYPE_PARTIALS = {
    "Wiki" => "pages/list",
    "asset" => "pages/list",
    "map" => "pages/list",
    "overlay" => "overlays/list"
  }.freeze
  BOX_PARTIALS = {
    "recent" => "pages/box",
    "most_viewed" => "pages/box"
  }


  # GET /search
  # TODO move @dom_id and @partial out of the controller logic some day
  def index
    if request.post?
      # form was POSTed with search query
      # let's redirect to nice GET search url like /me/search/text/abracadabra/person/2
      redirect_to_search_results
    else
      @page_type = @path.first_arg_for("type") ? @path.first_arg_for("type").camelize + 'Page' : 'WikiPage'
      @dom_id = params[:dom_id] || @page_type.underscore+"_list"
      @widget = params[:widget]
      @partial = params[:partial] || "pages/list"
      @tags = @path.args_for("tag")
      render_search_results
    end
  end


  def render_search_results
    @path.default_sort('updated_at') if @path.search_text.empty?

    if EXTERNAL_PAGE_TYPES.include?(@page_type)
      @pages = get_external_results
    else
      @pages = Page.paginate_by_path(@path, options_for_me({:method => :sphinx}.merge(pagination_params.merge({ :per_page => 2}))))
   end


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
      list_partial = @page_type == 'OverlayPage' ? 'overlays/list' : 'pages/list'
      render :update do |page|
        page[@dom_id].replace_html :partial => partial, :locals => { :pages => @pages, :title => I18n.t("page_search_title".to_sym, :type => I18n.t(:"dg_#{@page_type.underscore}"))}
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
  def partial
    if @widget
      BOX_PARTIALS[widget] || raise("you called an illegal widget")
    elsif @page_type
      PAGE_TYPE_PARTIALS[type.to_s] || raise("you called an illegal partial")
    end
  end

end
