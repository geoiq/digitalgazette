class MapsController < ApplicationController

  def index
    params[:query] = "*" unless params.include?("query")
    @maps, @tags = Map.search(params)
  end
  
  def show
    @maps, @tags = Map.search()
    @map = @maps.first
    @map_id = params[:id]
  end

  def all
    params[:query] = "*" unless params.include?("query")
    @maps, @tags = Map.search(params)
  end
end