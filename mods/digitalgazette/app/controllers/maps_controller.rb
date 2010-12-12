class MapsController < PagesController # TODO < ExternalPagesController
  helper :geocommons
  skip_before_filter :login_required
  stylesheet 'page_creation', :action => :new
  stylesheet 'messages'
  permissions 'pages', 'groups/base', 'groups/memberships', 'groups/requests'
  helper 'action_bar', 'tab_bar', 'groups'

  before_filter :get_page_type

  include PagesHelper
  # FIXME: do we really need that "all" action?
  def index
    @page_type = "map"
    render :template => 'pages/index'
  end

  def show
    @map = Geocommons::Map.find(params[:id], params[:format])
    @page = @map
    # send data instead of rendering the map, if a specific format is given
    send_data @map if params[:format]
  end

  def all
    get_page_type
    @maps = fetch_pages_for(@path) # TODO pass options for pagination and other things
   # @maps = Geocommons::Map.paginate(params.merge(:limit => 50))
   # @maps = Geocommons::Map.paginate(@path)
    @pages = @maps
    render :partial => 'pages/list', :layout => "base", :locals => { :pages => @maps, :title => @page_type}
    #    all_pages_list
    # TODO: bring back @tags
  end

  def upload
  end

  def new
  end
  def edit
  end

#
# Refactoring
#

  # get_pages # similar to SearchController
  # maybe subclass of PagesController



  def get_page_type
    @page_type = "map" || params[:page_type] # hardcoded by now
  end

  def fetch_page_for(id, format = :json)
    Crabgrass::ExternalAPI.for(@page_type.to_s).call(:find, id, format).first
  end


  def fetch_pages_for(path)
    Crabgrass::ExternalAPI.for(@page_type).call(:paginate, transform_path(path))
  end

  def transform_path(path)
    Crabgrass::ExternalPathFinder.convert(@page_type, path)
  end

end
