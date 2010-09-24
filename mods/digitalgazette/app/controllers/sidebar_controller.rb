class SidebarController < ApplicationController
  def index
    render :update do |page|
      page.replace_html('dg_sidebar_content', :partial => '/dg_sidebar/search')
      page << 'DigitalGazette.Sidebar.adjust();'
    end
  end

  def page
    type = params[:type]
    id = params[:id]
    @page = MODEL_NAMES[type].constantize.find(id)
    render :partial => "/sidebar/page/#{type}", :layout => false
  end
end
