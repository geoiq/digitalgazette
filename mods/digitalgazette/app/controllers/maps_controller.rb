class MapsController < ApplicationController
  helper :geocommons

  # FIXME: do we really need that "all" action?
  def index
    redirect_to :action => 'all'
  end

  def show
    @map = Geocommons::Map.find(params[:id])
  end

  def all
    @maps = Geocommons::Map.find(params.merge(:limit => 50))
    # TODO: bring back @tags
  end

  def upload
  end

  def new
  end
  def edit
  end
end
