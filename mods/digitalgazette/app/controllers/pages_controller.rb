class PagesController < ApplicationController
  include ControllerExtension::MapPopup
  
  def index
    
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