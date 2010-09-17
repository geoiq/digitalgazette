class MapsController < PagesController
  helper :geocommons
  skip_before_filter :login_required
  stylesheet 'page_creation', :action => :new
  stylesheet 'messages'
  permissions 'pages', 'groups/base', 'groups/memberships', 'groups/requests'
  helper 'action_bar', 'tab_bar', 'groups'
#  layout 'header'

  include PagesHelper
  # FIXME: do we really need that "all" action?
  def index
    redirect_to :action => 'all'
  end

  def show
#    @map = Geocommons::Map.find(params[:id])
    @map = get_page_for(params[:id])
  end

  def all
    get_page_type
    @maps = fetch_pages_for(@path) # TODO pass options for pagination and other things
#    @maps = Geocommons::Map.paginate(params.merge(:limit => 50))
#    @maps = Geocommons::Map.paginate(@path)
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
    @page_type = "map" || params[:page_type]
  end
  
  def fetch_page_for(id)
    Crabgrass::ExternalAPI.for(@page_type).call(:find, id)
  end
  
  
  def fetch_pages_for(path)
    Crabgrass::ExternalAPI.for(@page_type).call(:find, path)
  end
  
end
