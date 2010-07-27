class SearchController < ApplicationController

  # TODO: check if there is a less hacky way / if this way is sufficient
  # GET /search
  def index
    @page_type = params[:page_type] || "WikiPage"
    if request.post?
      # form was POSTed with search query
      # let's redirect to nice GET search url like /me/search/text/abracadabra/person/2
      redirect_to_search_results
    else
      render_search_results
    end
  end

end
