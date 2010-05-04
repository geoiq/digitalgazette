class MapsController < ApplicationController

  def index
    params[:query] = "*" unless params.include?("query")
    @maps, @tags = Map.search(params)
    @popular, @tags = Map.search(:query => "*", :limit => 5)
  end
  
  def show
    @maps, @tags = Map.search(:pk => params[:id])
    @map = @maps.first
    @map_id = params[:id]
  end

  def all
    params[:query] = "*" unless params.include?("query")
    @maps, @tags = Map.search(params)
  end
  
  def new
    
  end
  def edit
    
  end  
end