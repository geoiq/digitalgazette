class ReportsController < ApplicationController

  def index
    # @popular = Page.popular("AssetPage", 5)
    # @recent = Page.recent("AssetPage", 5)
    @popular = Page.find_by_path([['limit','5'], [ 'most_viewed', "5"], ['type', 'wiki_page']])
    @recent = Page.find_by_path([ ['limit','5'], [ 'ascending', 'created_at'], ['type', 'asset_page']])
    
    render :template => "pages/index", :locals => {:asset_type => "AssetPage"}
  end

end
