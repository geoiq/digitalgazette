class PagesController < ApplicationController
  include ControllerExtension::MapPopup
  
  def index
    # @popular = Page.popular("WikiPage", 5)
    # @recent = Page.recent("WikiPage", 5)
    # @popular = Page.find_by_path([ 'most_viewed', "5"], ['type', 'wiki_page'])
    
    render :template => "wiki_page/index"
  end
  
  def all
    params[:view] ||= 'networks'
    @path.default_sort('updated_at')
    @popular = Page.popular("WikiPage", 5)
    @recent = Page.recent("AssetPage", 5)
        
    fetch_pages_for @path
    rss_for_collection(all_me_pages_path, :all_pages_tab)
    render :action => "all"  #now it also works for the index action
  end  
  def search
    @path = parse_filter_path(params[:path])
    if @path.empty?
      redirect_to my_work_me_pages_url
    else
      all
    end
  end
end