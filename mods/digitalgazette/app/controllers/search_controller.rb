class SearchController < ApplicationController

  prepend_before_filter :prefix_path

  # backed up from reports_controller.rb
  #     # @popular = Page.popular("AssetPage", 5)
  #     # @recent = Page.recent("AssetPage", 5)
  #     @popular = Page.find_by_path([['limit','5'], [ 'most_viewed', "5"], ['type', 'wiki_page']])
  #     @recent = Page.find_by_path([ ['limit','5'], [ 'ascending', 'created_at'], ['type', 'asset_page']])


  SEARCHABLE_PAGE_TYPES = ["WikiPage","AssetPage","MapPage"].freeze

  # TODO: check if there is a less hacky way / if this way is sufficient
  # GET /search
  def index
    if request.post?
      # form was POSTed with search query
      # let's redirect to nice GET search url like /me/search/text/abracadabra/person/2
      redirect_to_search_results
    else
      @page_type = @path.first_arg_for("type") ? @path.first_arg_for("type").camelize + 'Page' : 'WikiPage'
      @tags = @path.args_for("tag")
      render_search_results
    end
  end


  def render_search_results
    @path.default_sort('updated_at') if @path.search_text.empty?

    # if no explicit page type is already set, we limit page types to those we actually want to search in
    merge_default_path
    @pages = Page.paginate_by_path(@path, options_for_me({:method => :sphinx}.merge(pagination_params)))

    # split results by page types
    split_by_page_types
    # fetch overlays from geocommons
    get_external_results

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
  end


  # mix in instance variables from the external api
  def get_external_results
    if @tags
      @overlays = Geocommons::RestAPI::Overlay.paginate_by_tag(*@tags)
    else
      @overlays = Geocommons::RestAPI::Overlay.paginate(:query => @path.arg_for("text"))
    end
  end

  # separate by page types into instance variables
  def split_by_page_types
    @grouped_pages = @pages.group_by{ |page| page.class.name}
    SEARCHABLE_PAGE_TYPES.each do |t|
      instance_variable_set(:"@#{t.downcase.pluralize}",@grouped_pages[t])
    end
  end


  # TODO think about doing this with path finder internals
  def merge_default_path
    merge_path = (["type"] << SEARCHABLE_PAGE_TYPES.map(&:underscore).join("/or/type")).flatten.join('/')
    @path.merge!("type/asset/or/type/wiki/or/type/map") unless @path.first_arg_for("type")
  end


  # add to the path
  def prefix_path
    if params[:page_type]
      @path.merge!(["type", params[:page_type]])
    end
  end

end
