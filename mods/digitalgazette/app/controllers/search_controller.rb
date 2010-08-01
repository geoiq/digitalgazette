class SearchController < ApplicationController

  prepend_before_filter :prefix_path

  # backed up from reports_controller.rb
  #     # @popular = Page.popular("AssetPage", 5)
  #     # @recent = Page.recent("AssetPage", 5)
  #     @popular = Page.find_by_path([['limit','5'], [ 'most_viewed', "5"], ['type', 'wiki_page']])
  #     @recent = Page.find_by_path([ ['limit','5'], [ 'ascending', 'created_at'], ['type', 'asset_page']])


  # TODO: check if there is a less hacky way / if this way is sufficient
  # GET /search
  def index
    if request.post?
      # form was POSTed with search query
      # let's redirect to nice GET search url like /me/search/text/abracadabra/person/2
      redirect_to_search_results
    else
      @page_type = @path.first_arg_for("type") ? @path.first_arg_for("type").camelize + 'Page' : 'WikiPage'
      render_search_results
    end
  end


  def prefix_path
    if params[:page_type]
      @path.merge!(["type", params[:page_type]])
    end
  end

end
