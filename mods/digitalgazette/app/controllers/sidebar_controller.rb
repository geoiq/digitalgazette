class SidebarController < ApplicationController
  include ApplicationHelper

  def index
    render :update do |page|
      page.replace_html('dg_sidebar_content', :partial => '/dg_sidebar/search')
      page << 'DigitalGazette.Sidebar.adjust();'
    end
  end

  def page
    type = params[:type]
    id = params[:id]
    @page = dg_page_class(type).find(id)
    render :partial => "/sidebar/page/#{type}", :layout => false
  end

end
