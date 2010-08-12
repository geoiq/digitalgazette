class MapsController < ApplicationController

  before_filter :enable_api

  def index
    params[:query] = "*" unless params.include?("query")
    @maps, @tags = MapPage.search(params) # FIXME @tags will be overridden in the next line
    @popular, @tags = MapPage.search(:query => "*", :limit => 50)
  end

  def show
    @maps, @tags = MapPage.search(:pk => params[:id])
    debugger
    @map = @maps.first
    @map_id = params[:id]
  end

  def all
    params[:query] = "*" unless params.include?("query")
    @maps, @tags = MapPage.search(params.merge(:limit => 50))
  end

  def upload
  end

  def new
  end
  def edit
  end

  protected

  def enable_api
    @api = api_for(:map)
  end

end
