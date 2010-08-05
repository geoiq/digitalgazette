class MapsController < ApplicationController

  def index
    params[:query] = "*" unless params.include?("query")
    @maps, @tags = MapPage.search(params)
    @popular, @tags = MapPage.search(:query => "*", :limit => 50)
  end

  def show
    @maps, @tags = MapPage.search(:pk => params[:id])
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
end
