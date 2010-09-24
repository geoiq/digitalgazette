class SidebarController < ApplicationController
  def index
    render :update do |page|
      page.replace_html('dg_sidebar_content', :partial => '/dg_sidebar/search')
      page << 'DigitalGazette.Sidebar.adjust();'
    end
  end
end
