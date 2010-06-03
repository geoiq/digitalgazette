class ReportsController < ApplicationController

  def index
    @popular = Page.popular("AssetPage", 5)
    @recent = Page.recent("AssetPage", 5)
    render :template => "pages/index", :locals => {:asset_type => "assets"}
  end

end
