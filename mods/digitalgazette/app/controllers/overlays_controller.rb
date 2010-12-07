class OverlaysController < PagesController # TODO < ExternalPagesController
  helper :geocommons
  skip_before_filter :login_required

  def show
    @overlay = Geocommons::Overlay.find(params[:id], params[:format] || :json)
    # send data instead of rendering the map, if a specific format is given
    send_data @overlay
  end

end
